class MembershipRenewals
  @queue = :metrics
  
  extend MetricsHelper
  extend CapsuleHelper
  extend MembershipHelper
  
  # Produce stats on when members are due to renew
  def self.perform
    data = {}
    # Get all members
    organisations = CapsuleCRM::Organisation.find_all(:tag => 'Membership')
    # Group by level
    grouped = organisations.group_by{|org| field(org, "Membership", "Level").text }
    # Count organisations renewing in various periods
    [4,13,26].each do |x|
      data[x] = grouped.map do |level,orgs|
        { level => orgs.count{ |org| field(org, "Membership", "Joined").date + membership_length[level] <= x.weeks.from_now.to_date } }
      end.reduce(:merge)
    end
    store_metric("membership-renewals", DateTime.now, data)
    
  end
  
end

