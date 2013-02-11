require 'leftronic'

def LeftronicPublisher
  @queue = :metrics
  
  def self.api
    @@leftronic ||= Leftronic.new ENV['LEFTRONIC_API_KEY']
  end
  
  def self.perform(datatype, id, data)
    case datatype
    when :html
      api.push id, html: data
    when :number
      api.push_number id, html: data
    else
      raise ArgumentError.new("Unknown data type in LeftronicPublisher: #{datatype}")
    end
  end

end