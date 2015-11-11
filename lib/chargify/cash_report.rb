require_relative "report"

module Reports
  class CashReport < Report
    def headers
      [
        'date',
        'company',
        'membership number',
        'statement id',
        'membership type',
        'transaction type',
        'coupon',
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
      table << headers

      transactions.keys.sort.each do |subscription_id|
        txns = transactions[subscription_id].group_by(&:type)
        if (txns.keys - %w[Refund]).present?
          vars = extract_identifiers(txns)

          charges  = txns['Charge'].group_by(&:kind)
          customer = @customers[vars[:customer_id]]
          product  = @products[vars[:product_id]]

          tax_amount = if charges['tax'].present?
            charges['tax'].first.amount_in_cents.to_i
          else
            0
          end

          totals['amount']   += charges['baseline'].first.amount_in_cents
          totals['discount'] += vars[:discount]
          totals['total']    += vars[:total]
          totals['tax']      += tax_amount

          table << [
            vars[:created_at].to_s(:db),
            company_name(customer),
            customer.reference.to_s,
            vars[:statement_id].to_s,
            product.handle,
            "payment",
            vars[:coupon].to_s,
            "%d" % (charges['baseline'].first.amount_in_cents/100),
            "%d" % (vars[:discount]/100),
            "%d" % (tax_amount/100),
            "%d" % (vars[:total]/100)
          ]
        end

        if txns['Refund'].present?
          txns['Refund'].each { |refund| table << refund_row(refund, totals) }
        end
      end

      table << total_row(totals)
      table
    end

    def total_row(totals)
      [
        "",
        "",
        "",
        "",
        "",
        "",
        "totals",
        (totals['amount']/100).to_s,
        (totals['discount']/100).to_s,
        (totals['tax']/100).to_s,
        (totals['total']/100).to_s
      ]
    end

    def company_name(customer)
      if customer.organization.present?
        customer.organization
      else
        [customer.first_name, customer.last_name].join(" ")
      end
    end

    def extract_identifiers(txns)
      obj = (txns['Payment'] || txns['Adjustment'] || txns['Charge']).first
      if obj.type == 'Adjustment'
        total = txns.values.flatten.select {|t| %w[Charge Adjustment].include?(t.type)}.sum(&:amount_in_cents)
        coupon_code = extract_coupon_code(obj)
        discount = obj.amount_in_cents
      else
        total = obj.amount_in_cents
        discount = 0
      end

      {
        customer_id: obj.customer_id,
        product_id: obj.product_id,
        statement_id: obj.statement_id,
        created_at: obj.created_at,
        discount: discount,
        coupon: coupon_code,
        total: total
      }
    end

    def extract_coupon_code(txn)
      /Coupon: (.+) -/.match(txn.memo)[1]
    end

    def refund_row(refund, totals)
      customer = @customers[refund.customer_id]
      product = @products[refund.product_id]
      txns = Chargify::Transaction.all(from: "/subscriptions/#{refund.subscription_id}/transactions").group_by(&:type) 
      payment = txns['Payment'].first
      charges = txns['Charge'].group_by(&:kind)
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
          "-%d" % (charges['baseline'].first.amount_in_cents/100),
          "0",
          "-%d" % (tax_amount/100),
          "-%d" % (payment.amount_in_cents.to_i/100)
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
          "-%d" % (refund.amount_in_cents.to_i/100),
          "0",
          "-%d" % (refund.amount_in_cents.to_i/100)
        ]
      end
    end
  end
end

