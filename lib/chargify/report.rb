module Reports
  class Report
    attr_reader :start_date, :end_date

    def initialize(start_date, end_date, transactions, customers, products, subscriptions)
      @start_date    = start_date
      @end_date      = end_date
      @transactions  = transactions
      @customers     = customers
      @products      = products
      @subscriptions = subscriptions
    end

    def report_date_range
      start_date..end_date
    end

    def generate
      CSV.generate(:encoding => 'utf-8') do |csv|
        data.each do |row|
          csv << row
        end
      end
    end

    def data
      raise ArgumentError, "You must implement `#data`"
    end
  end
end

