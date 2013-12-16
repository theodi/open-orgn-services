class PipelineMetrics
  @queue = :metrics
  
  extend Observable
  extend CapsuleHelper
  extend MetricsHelper
  
  def self.perform

    # Get all opportunities from CapsuleCRM
    opportunities = CapsuleCRM::Opportunity.find_all
    
    # Current financial period - sensibly, ours is aligned to calendar year
    start_date = Date.today.beginning_of_year
    one_year_end_date = Date.today.end_of_year
    # Next three financial years - including current
    three_year_end_date = one_year_end_date + 2.years

    # Work out pipeline totals
    total_pipeline = {}
    weighted_pipeline = {}
    [one_year_end_date, three_year_end_date].each do |end_date|
      # Find opportunities that have or are expected to close in the right time period
      relevant_opportunities = opportunities.select do |x| 
        close = Date.parse(x.actual_close_date || x.expected_close_date) rescue nil
        close.present? && close >= start_date && close <= end_date  
      end
      # Find only those which are open but expected to close
      open_relevant_opportunities = relevant_opportunities.select{|x| !opportunity_closed?(x)}
      # Total pipeline is sum of all relevant opportunities closing this year
      total_pipeline["#{start_date}/#{end_date}"] = relevant_opportunities.map{|x| x.value.to_i}.reduce(:+).to_i
      # Weighted pipeline is the weighted sum of all open relevant opportunities yet to close this year
      weighted_pipeline["#{start_date}/#{end_date}"] = open_relevant_opportunities.map{|x| x.value.to_i * (x.probability.to_i/100.0)}.reduce(:+).to_i
    end

    # Store
    store_metric("total-pipeline", DateTime.now, total_pipeline)
    store_metric("weighted-pipeline", DateTime.now, weighted_pipeline)

  end
  
end

