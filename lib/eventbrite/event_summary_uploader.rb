class EventSummaryUploader
  
  @queue = :invoicing
  
  # Public: Copies a JSON summary to a known file location (controlled by ENV variables)
  #
  # json - the JSON document to be uploaded
  #
  # Examples
  #
  #   EventSummaryUploader.perform("{'foo':'bar'}")
  #   # => nil
  #
  # Returns nothing
  def self.perform(json, type)
    filename = "/tmp/#{type}.json"
    # Write tempfile
    begin
      f = File.open(filename, "w")
      f.write json
    ensure
      f.close if f
    end
    # rsync the file to the right place
    type == "courses" ? path = ENV['COURSES_RSYNC_PATH'] : path = ENV['LECTURES_RSYNC_PATH']
    Kernel.system "rsync", filename, path
  end
  
end