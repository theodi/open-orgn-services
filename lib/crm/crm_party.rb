require "crm/crm_tag"

module CRM
  class Party
    attr_reader :record

    def initialize(record)
      @record = record
    end

    def contact_first_name
      CRM::Tag.text(record, "Membership", "Contact first name") do
        record.first_name if record.respond_to?(:first_name)
      end
    end

    def contact_last_name
      CRM::Tag.text(record, "Membership", "Contact last name") do
        record.last_name if record.respond_to?(:last_name)
      end
    end

    def email
      return nil if record.emails.empty?

      record.emails.first.address
    end

    def newsletter
      CRM::Tag.boolean(record, "Membership", "Newsletter")
    end

    alias_method :newsletter?, :newsletter

    def level
      CRM::Tag.text(record, "Membership", "Level")
    end

    def supporter_level
      CRM::Tag.text(record, "Membership", "Supporter Level")
    end

    def country
      CRM::Tag.text(record, "Membership", "Country")
    end

    def twitter
      CRM::Tag.text(record, "Membership", "Twitter")
    end

    def join_date
      CRM::Tag.date(record, "Membership", "Joined")
    end

    def organization_sector
      CRM::Tag.text(record, "Membership", "Sector")
    end

    def organization_name
      record.name if record.respond_to?(:name)
    end

    def organization_size
      CRM::Tag.text(record, "Membership", "Size")
    end
  end
end

