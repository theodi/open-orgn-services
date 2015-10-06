module CRM
  class Tag

    def self.boolean(record, tag, label, &block)
      new(record, :boolean, tag, label).value(&block)
    end

    def self.text(record, tag, label, &block)
      new(record, :text, tag, label).value(&block)
    end

    attr_reader :record, :type, :tag, :label

    def initialize(record, type, tag, label)
      @record = record
      @type   = type
      @tag    = tag
      @label  = label
    end

    def value(&block)
      field(tag, label).send(type)
    rescue ArgumentError
      if block_given?
        yield
      else
        default_value
      end
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

