module Reports
  class Report
    def initialize(transactions, customers, products)
      @transactions = transactions
      @customers    = customers
      @products     = products
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

