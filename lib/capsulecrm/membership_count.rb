class MembershipCount
  @queue = :metrics
  
  extend MetricsHelper
  extend CapsuleHelper
  
  # Count current members, split by level
  def self.perform
    
    # Get all members
    organisations = CapsuleCRM::Organisation.find_all(:tag => 'Membership')
    # Group by level
    grouped = organisations.group_by{|org| field(org, "Membership", "Level").text }
    # Count sizes of groups
    counts = grouped.map{ |level,orgs| {level => orgs.count} }.reduce(:merge)
    # Store
    data = {
      total: organisations.count,
      by_level: counts
    }
    store_metric("membership-count", DateTime.now, data)
    
  end
  
end

