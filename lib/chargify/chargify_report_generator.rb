require 'chargify_api_ares'
require 'csv'

require_relative 'booking_value_report'
require_relative 'cash_report'

class ChargifyReportGenerator
  @queue = :directory

  AVAILABLE_REPORTS = [:cash_report, :booking_value_report]

  def self.perform
    previous_month = Date.today.prev_month
    email = ENV.fetch('FINANCE_EMAIL')
    reporter = new(email, previous_month.beginning_of_month, previous_month.end_of_month)
    reporter.fetch_data
    reporter.send_report
  end

  def self.save_csvs
    previous_month = Date.today.prev_month
    reporter = new(nil, previous_month.beginning_of_month, previous_month.end_of_month)
    reporter.fetch_data
    reporter.save
  end

  def initialize(email, start_date, end_date)
    @email = email
    @start_date, @end_date = start_date, end_date
  end

  def save
    reports.each do |filename, report|
      File.open(filename, 'w') do |f|
        f.write(report)
      end
    end
  end

  def reports
    AVAILABLE_REPORTS.each_with_object({}) do |report, hash|
      key = "#{report.to_s.dasherize}.csv"
      klass = report_klass(report)

      hash[key] = klass.new(@transactions, @customers, @products).generate
    end
  end

  def report_klass(name)
    "Reports::#{name.to_s.camelize}".constantize
  end

  def send_report
    subject = "Membership finance report for #{@end_date.strftime("%B %Y")}"
    body = "For the dates between #{@start_date} and #{@end_date}"

    mail = Pony.mail({
      :to => @email,
      :cc => "members@theodi.org",
      :from => 'robots@theodi.org',
      :subject => subject,
      :body => body,
      :attachments => reports,
      :via => :smtp,
      :via_options => {
        :user_name => ENV["MANDRILL_USERNAME"],
        :password => ENV["MANDRILL_PASSWORD"],
        :domain => "theodi.org",
        :address => "smtp.mandrillapp.com",
        :port => 587,
        :authentication => :plain,
        :enable_starttls_auto => true
      }
    })
  end

  def fetch_data
    @products = Chargify::Product.all
    @transactions = []
    per_page = 20
    params = {since_date: @start_date.to_s, until_date: @end_date.to_s, per_page: per_page, page: 1}
    transactions = Chargify::Transaction.all(params: params)
    @transactions.concat(transactions)
    until transactions.size < per_page do
      params[:page] += 1
      transactions = Chargify::Transaction.all(params: params)
      @transactions.concat(transactions)
    end
    @customers = {}
    @transactions.map(&:customer_id).uniq.each do |id|
      @customers[id] = Chargify::Customer.find(id)
    end
    @products = {}
    @transactions.map(&:product_id).uniq.each do |id|
      @products[id] = Chargify::Product.find(id)
    end
  end
end

