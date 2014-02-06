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
      "current-year-active-reach"            => reach(current_year, "Active"),
      "current-year-passive-reach"           => reach(current_year, "Passive"),
      "current-year-bookings"                => bookings(current_year),
      "cumulative-bookings"                  => bookings(nil),
      "current-year-value-unlocked"          => value(current_year),
      "cumulative-value-unlocked"            => value(nil),
      "current-year-kpi-performance"         => kpis(current_year),
      "current-year-commercial-bookings"     => bookings_by_type("Commercial", current_year),
      "current-year-non-commercial-bookings" => bookings_by_type("Non-commercial", current_year),
      "current-year-grant-funding"           => grant_funding(current_year),
      "current-year-income-by-type"          => income_by_type(current_year),
      "current-year-income-by-sector"        => income_by_sector(current_year),
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

  def self.reach(year = nil, type = nil)
    if year.nil?
      years.inject(0) { |total, year| total += reach(year, type) }
    else
      metrics_cell("#{type} Reach".strip, year).to_i
    end
  end

  def self.bookings(year = nil)
    if year.nil?
      years.inject(0) { |total, year| total += bookings(year) }
    else
      metrics_cell('Bookings', year).to_i
    end
  end

  def self.value(year = nil)
    if year.nil?
      years.inject(0) { |total, year| total += value(year) }
    else
      metrics_cell('Value unlocked', year).to_i
    end
  end

  def self.network
    h         = {}
    h[:total] = metrics_cell('Network size').to_i

    breakdown              = {}
    breakdown[:members]    = metrics_cell('Members headline').to_i
    breakdown[:nodes]      = metrics_cell('Nodes headline').to_i
    breakdown[:startups]   = metrics_cell('Startups headline').to_i
    breakdown[:affiliates] = metrics_cell('Affiliates headline').to_i

    h[:breakdown] = breakdown

    h
  end

  def self.kpis(year)
    metrics_cell('KPI percentage', year).to_f.round(1)
  end

  def self.total_income(year)
    metrics_cell('Total income', year).to_i
  end

  def self.bookings_by_type(type, year)
    block = Proc.new { |x| x.to_f }
    metric_with_target "#{type} Bookings", year, block
  end

  def self.grant_funding(year)
    block = Proc.new { |x| x.to_f }
    metric_with_target 'Grant Funding', year, block
  end

  def self.income_by_type(year)
    {
        research: metrics_cell("Research income", year).to_f,
        training: metrics_cell("Training income", year).to_f,
        projects: metrics_cell("Project income", year).to_f,
        network:  metrics_cell("Network income", year).to_f
    }
  end

  def self.income_by_sector(year)
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
              commercial: "Commercial #{item.to_s} income",
              non_commercial: "Non-commercial #{item.to_s} income"
          }, year, block)]
        end
    ]
  end

  def self.headcount(year, month)
    index = month - 1
    block = Proc.new { |x| x[index].to_f }
    metric_with_target 'Headcount', year, block
  end

  def self.burn_rate(year, month)
    index = month - 1
    block = Proc.new { |x| x[index].to_f }
    metric_with_target 'Burn', year, block
  end

  def self.ebitda(year, month)
    index = month - 1
    block = Proc.new { |x| x[index].to_f }
    metric_with_target 'EBITDA', year, block
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

  def self.people_trained(year)
    block = Proc.new { |x| x.inject(0) { |sum, value| sum += value.to_i } }
    h     = {
        commercial:     'Commercial people trained',
        non_commercial: 'Non-commercial people trained'
    }

    extract_metric h, year, block
  end

  def self.network_size(year, month)
    block = Proc.new { |x| x.to_i }
    h     = {
        partners:   'Partners',
        sponsors:   'Sponsors',
        supporters: 'Supporters',
        startups:   'Startups',
        nodes:      'Nodes'
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
    multiplier = location['multiplier'] || @@lookups['default_multiplier']
    {
        actual: block.call(metrics_worksheet(location['document'], location['sheet'])[location['actual']]) * multiplier,
        annual_target: block.call(metrics_worksheet(location['document'], location['sheet'])[location['annual_target']]) * multiplier,
        ytd_target: block.call(metrics_worksheet(location['document'], location['sheet'])[location['ytd_target']].slice(0,month).inject(0.0){|sum,val| sum + val.to_f}) * multiplier,
    }
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
    @@lookups['cell_lookups'][year][identifier]
  end

  def self.metrics_cell identifier, year = nil
    year                 = Date.today.year if year.nil?
    location             = cell_location(year, identifier)
    location['document'] ||= @@lookups['document_keys'][environment]['default']
    multiplier = location['multiplier'] || @@lookups['default_multiplier']
    metrics_worksheet(location["document"], location["sheet"])[location["cell_ref"]].to_f * multiplier
  end

  def self.years
    2013..Date.today.year
  end

  def self.clear_cache!
    @@metrics_spreadsheets = {}
  end
end
