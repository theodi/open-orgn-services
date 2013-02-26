module AttendeeMonitorSupport
  
  def create_attendee_monitor_event_hash
    @events.last.compact
  end

end

World(AttendeeMonitorSupport)