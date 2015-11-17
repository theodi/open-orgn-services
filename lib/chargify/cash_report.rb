require_relative "report"

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

    def data
      table = []
      table << headers_row

      transactions.keys.sort.each do |subscription_id|
        subscriber_transactions = transactions[subscription_id].group_by(&:type)

        if (subscriber_transactions.keys - %w[Refund]).present?
          table << charge_row(subscriber_transactions)
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

    def charge_row(subscriber_transactions)
      vars = SubscriberTransaction.new(subscriber_transactions, @products, @customers)

      totals['amount']   += vars.net_price
      totals['discount'] += vars.discount
      totals['total']    += vars.total
      totals['tax']      += vars.tax_amount

      [
        vars.created_at.to_s(:db),
        vars.company_name,
        vars.customer_reference,
        vars.statement_id,
        vars.product_handle,
        "payment",
        vars.coupon_code,
        coupon_amount(vars.coupon_amount),
        "%d" % (vars.net_price / 100),
        "%d" % (vars.discount / 100),
        "%d" % (vars.tax_amount / 100),
        "%d" % (vars.total / 100)
      ]
    end

    def coupon_amount(amount)
      if amount.nil?
        ""
      else
        "%d%" % amount
      end
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
          "-%d" % (charges['baseline'].first.amount_in_cents / 100),
          "0",
          "-%d" % (tax_amount / 100),
          "-%d" % (payment.amount_in_cents.to_i / 100)
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
          "-%d" % (refund.amount_in_cents.to_i / 100),
          "0",
          "-%d" % (refund.amount_in_cents.to_i / 100)
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

    class SubscriberTransaction
      extend Forwardable

      attr_reader :transactions, :products, :customers

      def initialize(transactions, products, customers)
        @transactions = transactions
        @products     = products
        @customers    = customers
      end

      def obj
        (transactions['Payment'] || transactions['Adjustment'] || transactions['Charge']).first
      end

      def adjustment?
        obj.type == 'Adjustment'
      end

      def total
        if adjustment?
          charges_and_adjustments.sum(&:amount_in_cents)
        else
          obj.amount_in_cents
        end
      end

      def net_price
        charges['baseline'].first.amount_in_cents
      end

      def tax_amount
        if charges['tax'].present?
          charges['tax'].first.amount_in_cents.to_i
        else
          0
        end
      end

      def charges
        transactions['Charge'].group_by(&:kind)
      end

      def charges_and_adjustments
        transactions.values.flatten.select do |transaction|
          %w[Charge Adjustment].include?(transaction.type)
        end
      end

      def discount
        if adjustment?
          obj.amount_in_cents
        else
          0
        end
      end

      def_delegators :obj, :customer_id, :product_id, :statement_id, :created_at

      def customer
        @customers[customer_id]
      end

      def product
        @products[product_id]
      end

      def company_name
        if customer.organization.present?
          customer.organization
        else
          [customer.first_name, customer.last_name].join(" ")
        end
      end

      def customer_reference
        customer.reference.to_s
      end

      def product_handle
        product.handle
      end

      def coupon_code
        return "" unless adjustment?

        /Coupon: (.+) -/.match(obj.memo)[1]
      end

      def coupon_amount
        return if discount.zero?

        (discount.abs / (net_price / 100))
      end

    end
  end
end

