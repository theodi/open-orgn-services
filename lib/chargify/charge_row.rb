module Reports
  class ChargeRow
    attr_reader :charge

    def initialize(charge)
      @charge = charge
    end

    delegate :company_name, :customer_reference, :statement_id,
      :product_handle, :coupon_code, to: :charge

    def row
      [
        created_at,
        company_name,
        customer_reference,
        statement_id,
        product_handle,
        "payment",
        coupon_code,
        coupon_amount,
        net_price,
        discount,
        net_after_discount,
        tax_amount,
        total
      ]
    end

    def created_at
      charge.created_at.to_s(:db)
    end

    def net_price
      format_value(:net_price)
    end

    def discount
      format_value(:discount)
    end

    def net_after_discount
      format_value(:net_after_discount)
    end

    def tax_amount
      format_value(:tax_amount)
    end

    def total
      format_value(:total)
    end

    def coupon_amount
      if charge.coupon_amount.nil?
        ""
      else
        "%d%" % charge.coupon_amount
      end
    end

    private

    def format_value(value)
      "%.2f" % (charge.send(value).to_f / 100)
    end
  end
end

