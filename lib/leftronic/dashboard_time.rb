class DashboardTime
  
  @queue = :metrics
  
  def self.perform
    Resque.enqueue LeftronicPublisher, :html, ENV['LEFTRONIC_JENKINS_TIME'], "<div>#{DateTime.now.to_s}</div>"
  end

end