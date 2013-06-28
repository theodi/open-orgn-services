require 'jenkins-remote-api'

class BuildStatusMonitor
  
  @queue = :metrics
  
  def self.perform
    # Connect
    jenkins = Ci::Jenkins.new(ENV['JENKINS_URL'])
    # See if any builds have failed
    if jenkins.list_all_job_names.map{|x| jenkins.current_status_on_job(x)}.include?("failure")
      img = [
         'http://epicfail.xepher.net/wp-content/uploads/2010/12/epicfail1.jpg',
         'http://i0.kym-cdn.com/photos/images/original/000/029/367/shipment-of-fail.jpg?1318992465',
         'http://cdn.memegenerator.net/instances/400x/25381088.jpg',
         'http://cdn.memegenerator.net/instances/400x/26324172.jpg',
         'http://cdn.memegenerator.net/instances/400x/34551997.jpg',
         'http://mlkshk.com/r/OT39.gif',
         'https://pbs.twimg.com/media/BG2Yb-JCMAEmFIW.jpg:large',
         'http://cdn.memegenerator.net/instances/400x/37100162.jpg',
         'http://blogs.telegraph.co.uk/finance/files/2013/01/edBalls_1394334c.jpg',
         'http://i.imgur.com/HXPqs7I.gif'
      ].shuffle.first
      colour = 'red'
    else
      img = [
        'http://static.guim.co.uk/sys-images/Guardian/Pix/pictures/2012/9/5/1346860848383/Tim-Berners-Lee-008.jpg',
        'http://img3.rnkr-static.com/list_img/5342/385342/full/the-very-best-of-the-success-kid-meme.jpg?version=1355115667000',
      ].shuffle.first
      colour = 'green'
    end
    # Post HTML status
    html = <<-EOF
      <div style='background-color:#{colour}'>
        <img style='height:100%; margin-left: auto; margin-right: auto' src='#{img}'/>
      </div>
    EOF
    Resque.enqueue LeftronicPublisher, :html, ENV['LEFTRONIC_JENKINS_HTML'], html
  end
  
end
