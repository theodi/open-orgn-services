module CRM
  class Tag

    def self.boolean(record, tag, label)
      new(record, :boolean, tag, label).value
    end

    def self.text(record, tag, label)
      new(record, :text, tag, label).value
    end

    attr_reader :record, :type, :tag, :label

    def initialize(record, type, tag, label)
      @record = record
      @type   = type
      @tag    = tag
      @label  = label
    end

    def value
      field(tag, label).send(type)
    rescue ArgumentError
      default_value
    end

    private

    def field(tag, label)
      record.custom_fields.find(tag_missing) do |field|
        field.label == label && field.tag == tag
      end
    end

    def default_value
      nil
    end

    def tag_missing
      -> { raise ArgumentError }
    end
  end
end

