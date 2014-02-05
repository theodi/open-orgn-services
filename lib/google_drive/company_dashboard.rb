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
    breakdown[:members]    = metrics_cell('Members').to_i
    breakdown[:nodes]      = metrics_cell('Nodes').to_i
    breakdown[:startups]   = metrics_cell('Startups').to_i
    breakdown[:affiliates] = metrics_cell('Affiliates').to_i

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
    {
        actual: metrics_cell("#{type} Bookings Actual", year).to_f,
        target: metrics_cell("#{type} Bookings Target", year).to_f
    }
  end

  def self.grant_funding(year)
    {
        actual: metrics_cell("Grant Funding Actual", year).to_f,
        target: metrics_cell("Grant Funding Target", year).to_f
    }
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
    {
        research: {
            commercial:     {
                actual: metrics_cell("Commercial research income actual", year).to_f,
                target: metrics_cell("Commercial research income target", year).to_f
            },
            non_commercial: {
                actual: metrics_cell("Non-commercial research income actual", year).to_f,
                target: metrics_cell("Non-commercial research income target", year).to_f
            }
        },
        training: {
            commercial:     {
                actual: metrics_cell("Commercial training income actual", year).to_f,
                target: metrics_cell("Commercial training income target", year).to_f
            },
            non_commercial: {
                actual: metrics_cell("Non-commercial training income actual", year).to_f,
                target: metrics_cell("Non-commercial training income target", year).to_f
            }
        },
        projects: {
            commercial:     {
                actual: metrics_cell("Commercial projects income actual", year).to_f,
                target: metrics_cell("Commercial projects income target", year).to_f
            },
            non_commercial: {
                actual: metrics_cell("Non-commercial projects income actual", year).to_f,
                target: metrics_cell("Non-commercial projects income target", year).to_f
            }
        },
        network:  {
            commercial:     {
                actual: metrics_cell("Commercial network income actual", year).to_f,
                target: metrics_cell("Commercial network income target", year).to_f
            },
            non_commercial: {
                actual: metrics_cell("Non-commercial network income actual", year).to_f,
                target: metrics_cell("Non-commercial network income target", year).to_f
            }
        }
    }
  end

  def self.headcount(year, month)
    index = month - 1
    {
        actual: metrics_cell("Headcount actual", year)[index].to_f,
        target: metrics_cell("Headcount target", year)[index].to_f,
    }
  end

  def self.burn_rate(year, month)
    index = DateTime.now.month - 1
    {
        actual: metrics_cell("Burn actual", year)[index].to_f,
        target: metrics_cell("Burn target", year)[index].to_f,
    }
  end

  def self.ebitda(year, month)
    index = month - 1
    {
        actual: metrics_cell("EBITDA actual", year)[index].to_f,
        target: metrics_cell("EBITDA target", year)[index].to_f,
    }
  end

  def self.total_costs(year, month)
    index = month - 1
    {
        actual:    metrics_cell("Variable costs actual", year)[index].to_f + metrics_cell("Fixed costs actual", year)[index].to_f,
        target:    metrics_cell("Variable costs target", year)[index].to_f + metrics_cell("Fixed costs target", year)[index].to_f,

        breakdown: {
            variable: {
                research: {
                    actual: metrics_cell("Research costs actual", year)[index].to_f,
                    target: metrics_cell("Research costs target", year)[index].to_f
                },
                training: {
                    actual: metrics_cell("Training costs actual", year)[index].to_f,
                    target: metrics_cell("Training costs target", year)[index].to_f
                },
                projects: {
                    actual: metrics_cell("Projects costs actual", year)[index].to_f,
                    target: metrics_cell("Projects costs target", year)[index].to_f
                },
                network:  {
                    actual: metrics_cell("Network costs actual", year)[index].to_f,
                    target: metrics_cell("Network costs target", year)[index].to_f
                }
            },
            fixed:    {
                staff:                  {
                    actual: metrics_cell("Staff costs actual", year)[index].to_f,
                    target: metrics_cell("Staff costs target", year)[index].to_f
                },
                associates:             {
                    actual: metrics_cell("Associate costs actual", year)[index].to_f,
                    target: metrics_cell("Associate costs target", year)[index].to_f
                },
                office_and_operational: {
                    actual: metrics_cell("Office and operational costs actual", year)[index].to_f,
                    target: metrics_cell("Office and operational costs target", year)[index].to_f
                },
                delivery:               {
                    actual: metrics_cell("Delivery costs actual", year)[index].to_f,
                    target: metrics_cell("Delivery costs target", year)[index].to_f
                },
                communications:         {
                    actual: metrics_cell("Communications costs actual", year)[index].to_f,
                    target: metrics_cell("Communications costs target", year)[index].to_f
                },
                professional_fees:      {
                    actual: metrics_cell("Professional fees costs actual", year)[index].to_f,
                    target: metrics_cell("Professional fees costs target", year)[index].to_f
                },
                software:               {
                    actual: metrics_cell("Software costs actual", year)[index].to_f,
                    target: metrics_cell("Software costs target", year)[index].to_f
                }
            }
        }
    }

  end

  def self.people_trained(year)
    {
        commercial:     {
            actual: metrics_cell("Commercial people trained actual", year).inject(0) { |sum, value| sum += value.to_i },
            target: metrics_cell("Commercial people trained target", year).inject(0) { |sum, value| sum += value.to_i }
        },
        non_commercial: {
            actual: metrics_cell("Non-commercial people trained actual", year).inject(0) { |sum, value| sum += value.to_i },
            target: metrics_cell("Non-commercial people trained target", year).inject(0) { |sum, value| sum += value.to_i }
        }
    }
  end

  def self.network_size(year)
    block = Proc.new { |x| x.to_i }
    Hash[
        {
            partners:   'Partners',
            sponsors:   'Sponsors',
            supporters: 'Supporters',
            startups:   'Startups',
            nodes:      'Nodes'
        }.map { |key, value| [key, metric_with_target(value, year, block)] }
    ]
  end

  private

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
