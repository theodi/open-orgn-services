require 'google_drive'
require 'yaml'

class CompanyDashboard
  @@lookups = YAML.load(File.open(File.join(File.dirname(__FILE__), '..', '..', 'config/lookups.yaml')))

  @queue = :metrics

  extend MetricsHelper

  def self.perform
    current_year  = DateTime.now.year
    current_month = DateTime.now.month
    # reach
    store_metric("current-year-reach", DateTime.now, reach(current_year))
    store_metric("cumulative-reach", DateTime.now, reach(nil))
    store_metric("current-year-active-reach", DateTime.now, reach(current_year, "Active"))
    store_metric("current-year-passive-reach", DateTime.now, reach(current_year, "Passive"))
    # bookings
    store_metric("current-year-bookings", DateTime.now, bookings(current_year))
    store_metric("cumulative-bookings", DateTime.now, bookings(nil))
    # value-unlocked
    store_metric("current-year-value-unlocked", DateTime.now, value(current_year))
    store_metric("cumulative-value-unlocked", DateTime.now, value(nil))
    # performance against KPIs
    store_metric("current-year-kpi-performance", DateTime.now, kpis(current_year))
    # commercial bookings
    store_metric("current-year-commercial-bookings", DateTime.now, bookings_by_type("Commercial", current_year))
    store_metric("current-year-non-commercial-bookings", DateTime.now, bookings_by_type("Non-commercial", current_year))
    # grant funding
    store_metric("current-year-grant-funding", DateTime.now, grant_funding(current_year))
    # income by type
    store_metric("current-year-income-by-type", DateTime.now, income_by_type(current_year))
    # income by sector
    store_metric("current-year-income-by-sector", DateTime.now, income_by_sector(current_year))
    # headcount
    store_metric("current-year-headcount", DateTime.now, headcount(current_year, current_month))
    # burn
    store_metric("current-year-burn", DateTime.now, burn_rate(current_year, current_month))
    # training
    store_metric("current-year-people-trained", DateTime.now, people_trained(current_year))
    # network
    store_metric("current-year-network-size", DateTime.now, network_size(current_year))
    # cashflow
    store_metric("current-year-ebitda", DateTime.now, ebitda(current_year, current_month))
    store_metric("current-year-total-costs", DateTime.now, total_costs(current_year, current_month))
    # Done - clear cached sheet
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
              commercial:"Commercial #{item.to_s} income",
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
    index = month - 1
    block = Proc.new { |x| x[index].to_f }
    {
        actual:    metrics_cell("Variable costs actual", year)[index].to_f + metrics_cell("Fixed costs actual", year)[index].to_f,
        target:    metrics_cell("Variable costs target", year)[index].to_f + metrics_cell("Fixed costs target", year)[index].to_f,

        breakdown: {
            variable: extract_metric(
                          {
                              research: 'Research costs',
                              training: 'Training costs',
                              projects: 'Projects costs',
                              network:  'Network costs'
                          }, year, block),
            fixed:    extract_metric(
                          {
                              staff:                  'Staff costs',
                              associates:             'Associate costs',
                              office_and_operational: 'Office and operational costs',
                              delivery:               'Delivery costs',
                              communications:         'Communications costs',
                              professional_fees:      'Professional fees costs',
                              software:               'Software costs'
                          }, year, block)
        }
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

  def self.network_size(year)
    block = Proc.new { |x| x.to_i }
    h     = {
        partners:   'Partners',
        sponsors:   'Sponsors',
        supporters: 'Supporters',
        startups:   'Startups',
        nodes:      'Nodes'
    }

    extract_metric h, year, block
  end

  private

  def self.extract_metric h, year, block
    Hash[h.map { |key, value| [key, metric_with_target(value, year, block)] }
    ]
  end

  def self.metric_with_target name, year = nil, block
    {
        actual: block.call(metrics_cell("#{name} actual", year)),
        target: block.call(metrics_cell("#{name} target", year))
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
    metrics_worksheet(location["document"], location["sheet"])[location["cell_ref"]]
  end

  def self.years
    2013..Date.today.year
  end

  def self.clear_cache!
    @@metrics_spreadsheets = {}
  end
end
