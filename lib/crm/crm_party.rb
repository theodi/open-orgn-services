module CRM
  class Party
    attr_reader :record

    def initialize(record)
      @record = record
    end

    def email
      record.emails.first.address
    end

    def newsletter
      if field = custom_field("Membership", "Newsletter")
        return field.boolean
      end

      false
    end

    alias_method :newsletter?, :newsletter

    private

    def custom_field(tag, label)
      record.custom_fields.find do |field|
        field.label == "Newsletter" && field.tag == "Membership"
      end
    end
  end
end

