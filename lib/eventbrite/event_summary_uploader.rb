class EventSummaryUploader
  
  @queue = :invoicing
  
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