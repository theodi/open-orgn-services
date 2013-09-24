require 'jenkins-remote-api'

class BuildStatusMonitor
  
  @queue = :metrics
  
  def self.perform
    # Connect
    jenkins = Ci::Jenkins.new(ENV['JENKINS_URL'])
    # See if any builds have failed
    if jenkins.list_all_job_names.map{|x| jenkins.current_status_on_job(x)}.include?("failure")
      img = "https://buildmemes.herokuapp.com/f"
      colour = 'red'
    else
      img = "https://buildmemes.herokuapp.com/p"
      colour = 'green'
    end
    # Post HTML status
    html = <<-EOF
      <div style='background-color:#{colour}'>
        <img style='height:100%; margin-left: auto; margin-right: auto' src='#{img}'/>
      </div>
    EOF
    Resque.enqueue LeftronicPublisher, :html, ENV['LEFTRONIC_JENKINS_HTML'], html
  rescue RuntimeError
    # Sometimes the Jenkins CI gem will complain if there's any projects with a 'notbuilt' status. Just rescue from these an move on for now 
    nil
  end
  
end
