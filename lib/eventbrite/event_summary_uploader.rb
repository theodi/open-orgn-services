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
  def self.perform(json)
    filename = "/tmp/courses.json"
    # Write tempfile
    begin
      f = File.open(filename, "w")
      f.write json
    ensure
      f.close if f
    end
    # rsync the file to the right place
    Kernel.system "rsync", filename, ENV['COURSES_RSYNC_PATH']
  end
  
end