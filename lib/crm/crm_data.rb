require "active_support/core_ext/string"
require 'crm/crm_party'

module CRM
  class Data
    def self.find(type, id)
      new(type).find(id)
    end

    attr_writer :datasource

    def initialize(type)
      @type = type
    end

    def datasource
      @datasource ||= datasource_name.constantize
    end

    def datasource_name
      "CapsuleCRM::#{type}"
    end

    def type
      @type.to_s.titleize
    end

    def find(id)
      CRM::Party.new(datasource.find(id))
    end
  end
end

