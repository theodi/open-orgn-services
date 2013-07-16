require 'leftronic'

class LeftronicPublisher
  
  @queue = :metrics
  
  def self.api
    @@leftronic ||= Leftronic.new ENV['LEFTRONIC_API_KEY']
  end
  
  def self.perform(datatype, id, data)
    case datatype.to_sym # because it turns into a string when being JSON serialised
    when :html
      api.push id, html: data
    when :number
      api.push_number id, data
    else
      raise ArgumentError.new("Unknown data type in LeftronicPublisher: #{datatype}")
    end
  rescue Timeout::Error
    # Silently absorb timeouts, leftronic does this on a regular basis, but we don't really care.
    nil
  end

end