require 'google_drive'
require 'yaml'

class CompanyDashboard
  @@lookups = YAML.load(File.open(File.join(File.dirname(__FILE__), '..', '..', 'config/lookups.yaml')))

  @queue = :metrics

  extend MetricsHelper

  def self.perform
    current_year = DateTime.now.year
    # reach
    store_metric("current-year-reach", DateTime.now, reach(current_year))
    store_metric("cumulative-reach", DateTime.now, reach(nil))
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
    # Done - clear cached sheet
    clear_cache!
  end

  def self.reach(year = nil)
    if year.nil?
      years.inject(0) { |total, year| total += reach(year) }
    else
      metrics_cell('Reach', year).to_i
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
  end
  
  private

    def self.google_drive
      GoogleDrive.login(ENV['GAPPS_USER_EMAIL'], ENV['GAPPS_PASSWORD'])
    end

    def self.metrics_spreadsheet(doc_name)
      key = @@lookups['document_keys'][ENV['RACK_ENV'] || 'production'][doc_name]
      @@metrics_spreadsheets ||= {}
      @@metrics_spreadsheets[key] ||= google_drive.spreadsheet_by_key(key)
    end

    def self.metrics_worksheet doc_name, worksheet_name
      metrics_spreadsheet(doc_name).worksheet_by_title worksheet_name.to_s
    end

    def self.cell_location year, identifier
      @@lookups['cell_lookups'][year][identifier]
    end

    def self.metrics_cell identifier, year = nil
      year = Date.today.year if year.nil?
      location = cell_location(year, identifier)
      metrics_worksheet(location["document"], location["sheet"])[location["cell_ref"]]
    end

    def self.years
      2013..Date.today.year
    end

    def self.clear_cache!
      @@metrics_spreadsheets = {}
    end
end
