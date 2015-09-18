require "crm/crm_tag"

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
      CRM::Tag.boolean(record, "Membership", "Newsletter")
    end

    alias_method :newsletter?, :newsletter

    def level
      CRM::Tag.text(record, "Membership", "Level")
    end
  end
end

