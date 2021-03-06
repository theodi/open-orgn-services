require_relative "report"
require_relative "charge"

module Reports
  class CashReport < Report
    SPACER = ""

    def headers_row
      [
        'date',
        'company',
        'membership number',
        'statement id',
        'membership type',
        'transaction type',
        'coupon',
        'coupon amount',
        'original net price',
        'discount',
        'net after discount',
        'tax',
        'total'
      ]
    end

    def totals
      @totals ||= {
        'amount'   => 0,
        'tax'      => 0,
        'discount' => 0,
        'total'    => 0
      }
    end

    def transactions
      @transactions.group_by(&:subscription_id)
    end

    def payments
      @transactions.select { |t| t.type == "Payment" }
    end

    def adjustments
      @transactions.select { |t| t.type == "Adjustment" }
    end

    def subscription_is_cancelled?(subscription_id)
      subscription = @subscriptions.find { |s| s.id == subscription_id }
      subscription.state == "canceled"
    end

    def has_payment?(charge)
      payments.find do |payment|
        payment.subscription_id == charge.subscription_id
      end
    end

    def has_adjustment?(charge)
      adjustments.find do |adjustment|
        adjustment.subscription_id == charge.subscription_id
      end
    end

    def transactions_for_subscription(subscription_id)
      subscription_transactions = transactions[subscription_id]

      subscription_transactions.each do |transaction|
        next unless transaction.type == "Charge"

        if !transaction.amount_in_cents.zero? && !has_adjustment?(transaction)
          if !has_payment?(transaction)
            return {}
          end
        end
      end

      subscription_transactions.group_by(&:type)
    end

    def data
      table = []
      table << headers_row

      transactions.keys.sort.each do |subscription_id|
        subscriber_transactions = transactions_for_subscription(subscription_id)

        next if subscription_is_cancelled?(subscription_id)

        if (subscriber_transactions.keys - %w[Payment Refund InfoTransaction]).present?
          row = Charge.new(subscriber_transactions, @products, @customers)

          totals['amount']   += row.net_price
          totals['discount'] += row.discount
          totals['total']    += row.total
          totals['tax']      += row.tax_amount

          table << row.to_row
        end

        if subscriber_transactions['Refund'].present?
          subscriber_transactions['Refund'].each do |refund|
            table << refund_row(refund)
          end
        end
      end

      table << total_row
      table
    end

    def total_row
      [
        SPACER,
        SPACER,
        SPACER,
        SPACER,
        SPACER,
        SPACER,
        "totals",
        SPACER,
        total_net,
        total_discount,
        SPACER,
        total_tax,
        total
      ]
    end

    def total_net
      (totals['amount'] / 100).to_s
    end

    def total
      (totals['total'] / 100).to_s
    end

    def total_discount
      (totals['discount'] / 100).to_s
    end

    def total_tax
      (totals['tax'] / 100).to_s
    end

    def refund_row(refund)
      customer = @customers[refund.customer_id]
      product = @products[refund.product_id]
      refund_transactions = Chargify::Transaction.all(from: "/subscriptions/#{refund.subscription_id}/transactions").group_by(&:type)
      payment = refund_transactions['Payment'].first
      charges = refund_transactions['Charge'].group_by(&:kind)
      if payment.amount_in_cents == refund.amount_in_cents
        totals['amount'] -= charges['baseline'].first.amount_in_cents
        if charges['tax'].present?
          tax_amount = charges['tax'].first.amount_in_cents.to_i
          totals['tax'] -= tax_amount
        else
          tax_amount = 0
        end
        totals['total'] -= payment.amount_in_cents
        [
          refund.created_at.to_s(:db),
          company_name(customer),
          customer.reference,
          refund.statement_id.to_s,
          product.handle,
          "refund",
          "",
          "",
          "-%.2f" % (charges['baseline'].first.amount_in_cents / 100),
          "0.00",
          "",
          "-%.2f" % (tax_amount / 100),
          "-%.2f" % (payment.amount_in_cents.to_i / 100)
        ]
      else
        totals['amount'] -= refund.amount_in_cents
        totals['total'] -= refund.amount_in_cents
        [
          refund.created_at.to_s(:db),
          customer.reference,
          refund.statement_id.to_s,
          product.handle,
          "refund",
          "",
          "-%.2f" % (refund.amount_in_cents.to_i / 100),
          "0",
          "-%.2f" % (refund.amount_in_cents.to_i / 100)
        ]
      end
    end

    def company_name(customer)
      if customer.organization.present?
        customer.organization
      else
        [customer.first_name, customer.last_name].join(" ")
      end
    end
  end
end

