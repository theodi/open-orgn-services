class MembershipCoverage
  @queue = :metrics
  
  extend Observable
  extend CapsuleHelper
  extend MetricsHelper
  extend ProductHelper
  
  def self.perform

    data = {}

    sectors.each do |sector|
      # Load parties in the sector
      parties = CapsuleCRM::Organisation.find_all(tag: sector) + CapsuleCRM::Person.find_all(tag: sector)
      # Split by level
      grouped = parties.group_by{|org| x = field(org, "Membership", "Level"); x ? x.text : nil }
      # Count up
      products.each do |product|
        data[product] ||= {}
        data[product][sector] = (grouped[product.to_s] || []).count
      end
    end

    # Store
    store_metric("membership-coverage", DateTime.now, data)

  end
  
end

