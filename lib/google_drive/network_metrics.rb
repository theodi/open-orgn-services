class NetworkMetrics

  @queue = :metrics

  extend MetricsHelper
  extend GoogleDriveHelper

  def self.perform
    current_year  = DateTime.now.year
    current_month = DateTime.now.month
    {
      "current-year-reach"                   => reach(current_year),
      "cumulative-reach"                     => reach(nil),
      "current-year-pr-pieces"               => pr_pieces(current_year),
      "current-year-people-trained"          => people_trained(current_year, current_month),
      "cumulative-people-trained"            => people_trained(nil, nil),
      "current-year-network-size"            => network_size(current_year, current_month),
      "cumulative-network-size"              => network_size(nil, nil)
    }.each_pair do |metric, value|
      store_metric metric, DateTime.now, value
    end
    clear_cache!
  end

  def self.reach(year = nil)
    if year.nil?
      years.map{|year| reach(year)}.inject do |memo, reach|
        memo = {
          total: memo[:total] + reach[:total],
          breakdown: {
            active:  memo[:breakdown][:active] + reach[:breakdown][:active],
            passive: memo[:breakdown][:passive] + reach[:breakdown][:passive],
          }
        }
      end
    else
      {
        total:   metrics_cell("Total Reach", year, Proc.new {|x| x.to_i}),
        breakdown: {
          active:  metrics_cell("Active Reach", year, Proc.new {|x| x.to_i}),
          passive: metrics_cell("Passive Reach", year, Proc.new {|x| x.to_i}),
        }
      }
    end
  end

  def self.pr_pieces(year)
    block = Proc.new { |x| x.to_i }
    metrics_cell('PR Pieces', year, block)
  end

  def self.people_trained(year, month)
    if year.nil? && month.nil?
      block = Proc.new { |x| x.to_i }
      metrics_cell('People trained cumulative', nil, block)
    else
      block = Proc.new { |x| x.to_i }
      h     = {
          commercial:     'Commercial people trained',
          non_commercial: 'Non-commercial people trained'
      }

      extract_metric h, year, month, block
    end
  end

  def self.network_size(year, month)
    if year.nil? && month.nil?
      block = Proc.new { |x| x.to_i }
      metrics_cell('Network size cumulative', nil, block)
    else
      block = Proc.new { |x| x.to_i }
      h     = {
          partners:   'Partners',
          sponsors:   'Sponsors',
          supporters: 'Supporters',
          startups:   'Startups',
          nodes:      'Nodes',
          affiliates: 'Affiliates',
      }
      extract_metric h, year, month, block
    end
  end

end
