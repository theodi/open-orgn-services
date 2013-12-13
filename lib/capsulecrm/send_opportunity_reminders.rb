class SendOpportunityReminders
  @queue = :metrics
  
  extend CapsuleHelper
  
  def self.perform
    
    # Get open opportunities from CapsuleCRM
    opportunities = CapsuleCRM::Opportunity.find_all.select{|x| !opportunity_closed?(x)}
    # Get list of old opportunities
    old = opportunities.select{|x| x.created_at.to_date < 90.days.ago.to_date }
    # Get user list
    users = CapsuleCRM::User.find_all
    # Send emails
    old.each do |opportunity|

      owner = users.find{|x| x.username == opportunity.owner}
      owner = CapsuleCRM::Person.find(owner.party_id)
      
      party = CapsuleCRM::Party.find(opportunity.party_id)
      party_name = party.is_a?(CapsuleCRM::Organisation) ? party.name : [party.first_name, party.last_name].join(' ')
      body = <<-EOF
      Hi,
      
      This is your friendly reminder that there is an opportunity for #{party_name} that needs dealing with.
      
      Update the opportunity status at http://theodi.capsulecrm.com/opportunity/#{opportunity.id}.
      
      EOF
      Pony.mail({
        :to => owner.emails[0].address,
        :from => 'robots@theodi.org',
        :subject => "Old opportunity reminder: #{(Date.today - opportunity.created_at.to_date).to_i} days old",
        :body => body,
        :via => :smtp,
        :via_options => {
          :user_name => ENV["MANDRILL_USERNAME"],
          :password => ENV["MANDRILL_PASSWORD"],
          :domain => "theodi.org",
          :address => "smtp.mandrillapp.com",
          :port => 587,
          :authentication => :plain,
          :enable_starttls_auto => true
        }
      })
    end
    
  end
  
end