class AverageOpportunityAge
  @queue = :metrics
  
  extend MetricsHelper
  extend CapsuleHelper
  
  def self.perform
    
    # Get open opportunities from CapsuleCRM
    opportunities = CapsuleCRM::Opportunity.find_all.select{|x| !opportunity_closed?(x)}
    # Work out ages
    ages = opportunities.map{|x| Date.today - x.created_at.to_date }
    average = ages.reduce(:+) / opportunities.length.to_f
    # Store
    store_metric("average-opportunity-age", DateTime.now, average.to_i)
    
  end
  
end