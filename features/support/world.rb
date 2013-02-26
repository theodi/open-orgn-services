module GenericSupport
  
  # Utility functions to marshal setup variables into appropriate hashes

  def event_details
    @events.last.compact
  end

end

World(GenericSupport)