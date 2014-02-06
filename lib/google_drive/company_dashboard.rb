require 'google_drive'
require 'yaml'

class CompanyDashboard
  @@lookups = YAML.load(File.open(File.join(File.dirname(__FILE__), '..', '..', 'config/lookups.yaml')))

  @queue = :metrics

  extend MetricsHelper

  def self.perform
    current_year  = DateTime.now.year
    current_month = DateTime.now.month
    {
      "current-year-reach"                   => reach(current_year),
      "cumulative-reach"                     => reach(nil),
      "current-year-bookings"                => bookings(current_year),
      "cumulative-bookings"                  => bookings(nil),
      "current-year-value-unlocked"          => value(current_year),
      "cumulative-value-unlocked"            => value(nil),
      "current-year-pr-pieces"               => pr_pieces(current_year),
      "current-year-kpi-performance"         => kpis(current_year),
      "current-year-grant-funding"           => grant_funding(current_year),
      "current-year-bookings-by-sector"      => bookings_by_sector(current_year),
      "current-year-headcount"               => headcount(current_year, current_month),
      "current-year-burn"                    => burn_rate(current_year, current_month),
      "current-year-people-trained"          => people_trained(current_year),
      "current-year-network-size"            => network_size(current_year, current_month),
      "current-year-ebitda"                  => ebitda(current_year, current_month),
      "current-year-total-costs"             => total_costs(current_year, current_month),
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

  def self.bookings(year = nil)
    if year.nil?
      years.inject(0) { |total, year| total += bookings(year) }
    else
      metrics_cell('Bookings', year).to_i
    end
  end

  def self.pr_pieces(year)
    block = Proc.new { |x| x.to_i }
    metrics_cell('PR Pieces', year, block)
  end

  def self.value(year = nil)
    if year.nil?
      years.inject(0) { |total, year| total += value(year) }
    else
      metrics_cell('Value unlocked', year, Proc.new {|x| x.to_i })
    end
  end

  def self.kpis(year)
    metrics_cell('KPI percentage', year, Proc.new {|x| x.to_f}).round(1)
  end

  def self.income(year, month)
    metric_with_target('Income', year, month, Proc.new {|x| x.to_f})
  end

  def self.grant_funding(year, month)
    block = Proc.new { |x| x.to_f }
    metric_with_target 'Grant Funding', year, month, block
  end

  def self.bookings_by_sector(year, month)
    block = Proc.new { |x| x.to_f }
    Hash[
        [
        :research,
        :training,
        :projects,
        :network
    ].map do |item|
      [item, extract_metric(
          {
              commercial: "Commercial #{item.to_s} bookings",
              non_commercial: "Non-commercial #{item.to_s} bookings"
          }, year, month, block)]
        end
    ]
  end

  def self.headcount(year, month)
    block = Proc.new { |x| x.is_a?(Array) ? x[month-1].to_f : x.to_f }
    metric_with_target 'Headcount', year, month, block
  end

  def self.burn_rate(year, month)
    block = Proc.new { |x| x[month-1].to_f }
    metrics_cell 'Burn', year, block
  end

  def self.ebitda(year, month)
    block = Proc.new { |x| x.to_f }
    metric_with_target 'EBITDA', year, month, block
  end

  def self.total_costs(year, month)
    block = Proc.new { |x| x.to_f }
    breakdown = {
      variable: extract_metric(
                    {
                        research: 'Research costs',
                        training: 'Training costs',
                        projects: 'Projects costs',
                        network:  'Network costs'
                    }, year, month, block),
      fixed:    extract_metric(
                    {
                        staff:                  'Staff costs',
                        associates:             'Associate costs',
                        office_and_operational: 'Office and operational costs',
                        delivery:               'Delivery costs',
                        communications:         'Communications costs',
                        professional_fees:      'Professional fees costs',
                        software:               'Software costs'
                    }, year, month, block)
    }
    variable = metric_with_target("Variable costs", year, month, block)
    fixed    = metric_with_target("Fixed costs", year, month, block)
    # Smoosh it all together
    {
        actual:        variable[:actual] + fixed[:actual],
        annual_target: variable[:annual_target] + fixed[:annual_target],
        ytd_target:    variable[:ytd_target] + fixed[:ytd_target],
        breakdown: breakdown
    }    
  end

  def self.people_trained(year, month)
    block = Proc.new { |x| x.to_i }
    h     = {
        commercial:     'Commercial people trained',
        non_commercial: 'Non-commercial people trained'
    }

    extract_metric h, year, month, block
  end

  def self.network_size(year, month)
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

  private

  def self.extract_metric h, year, month, block
    Hash[h.map { |key, value| [key, metric_with_target(value, year, month, block)] }
    ]
  end

  def self.metric_with_target name, year, month, block
    location             = cell_location(year, name)
    location['document'] ||= @@lookups['document_keys'][environment]['default']
    ytd_method = location['ytd_method'] || @@lookups['default_ytd_method']
    ytd_aggregator = case ytd_method
    when "sum"
      Proc.new {|x| x.inject(0.0){|sum,val| sum + val.to_f}}
    when "latest"
      Proc.new {|x| x.last.to_f}
    end
    multiplier = location['multiplier'] || @@lookups['default_multiplier']
    data = {}
    data[:actual] = (block.call(
            metrics_worksheet(location['document'], location['sheet'])[location['actual']]
          ) * multiplier) if location['actual']
    data[:annual_target] = (block.call(
            metrics_worksheet(location['document'], location['sheet'])[location['annual_target']]
          ) * multiplier) if location['annual_target']
    data[:ytd_target] = (block.call(
            ytd_aggregator.call(
              metrics_worksheet(location['document'], location['sheet'])[location['ytd_target']].slice(0,month)
            )
          ) * multiplier) if location['ytd_target']
    data
  end

  def self.google_drive
    GoogleDrive.login(ENV['GAPPS_USER_EMAIL'], ENV['GAPPS_PASSWORD'])
  end

  def self.metrics_spreadsheet(doc_name)
    key                         = @@lookups['document_keys'][environment][doc_name]
    @@metrics_spreadsheets      ||= {}
    @@metrics_spreadsheets[key] ||= google_drive.spreadsheet_by_key(key)
  end

  def self.metrics_worksheet doc_name, worksheet_name
    metrics_spreadsheet(doc_name).worksheet_by_title worksheet_name.to_s
  end

  def self.cell_location year, identifier
    year = Date.today.year if year.nil?
    @@lookups['cell_lookups'][year][identifier]
  end

  def self.metrics_cell identifier, year, block
    location             = cell_location(year, identifier)
    location['document'] ||= @@lookups['document_keys'][environment]['default']
    multiplier = location['multiplier'] || @@lookups['default_multiplier']
    block.call(metrics_worksheet(location["document"], location["sheet"])[location["cell_ref"]]) * multiplier
  end

  def self.years
    2013..Date.today.year
  end

  def self.clear_cache!
    @@metrics_spreadsheets = {}
  end
end
