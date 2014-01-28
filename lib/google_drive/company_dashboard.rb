require 'google_drive'

class CompanyDashboard
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
    # Done - clear cached sheet
    clear_cache!
  end

  def self.reach(year = nil)
    if year.nil?
      years.inject(0) { |total, year| total += reach(year) }
    else
      metrics_worksheet(year)[1, 2].to_i
    end
  end

  def self.bookings(year = nil)
    if year.nil?
      years.inject(0) { |total, year| total += bookings(year) }
    else
      metrics_worksheet(year)[4, 2].to_i
    end
  end

  def self.value(year = nil)
    if year.nil?
      years.inject(0) { |total, year| total += value(year) }
    else
      metrics_worksheet(year)[3, 2].to_i
    end
  end

  def self.kpis(year)
    metrics_worksheet(year)[2, 2].to_f.round(1)
  end

  def self.google_drive
    GoogleDrive.login(ENV['GAPPS_USER_EMAIL'], ENV['GAPPS_PASSWORD'])
  end

  def self.metrics_spreadsheet
    @@metrics_spreadsheet ||= google_drive.spreadsheet_by_key(ENV['GAPPS_METRICS_SPREADSHEET_ID'])
  end

  def self.metrics_worksheet(year)
    metrics_spreadsheet.worksheet_by_title year.to_s
  end

  def self.years
    2013..Date.today.year
  end
  
  def self.clear_cache!
    @@metrics_spreadsheet = nil
  end
    
end
