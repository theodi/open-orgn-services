require 'chargify_api_ares'
require 'csv'

class ChargifyReportGenerator
  @queue = :directory

  def self.perform
    previous_month = Date.today.prev_month
    email = ENV.fetch('FINANCE_EMAIL')
    reporter = new(email, previous_month.beginning_of_month, previous_month.end_of_month)
    reporter.fetch_data
    reporter.send_report
  end

  def initialize(email, start_date, end_date)
    @email = email
    @start_date, @end_date = start_date, end_date
  end

  def send_report
    subject = "Membership finance report for #{@end_date.strftime("%B %Y")}"
    body = "For the dates between #{@start_date} and #{@end_date}"
    cash_report_csv = generate_csv(cash_report)
    booking_value_report_csv = generate_csv(booking_value_report)

    mail = Pony.mail({
      :to => @email,
      :from => 'robots@theodi.org',
      :subject => subject,
      :body => body,
      :attachments => {
        "cash-report.csv" => cash_report_csv,
        "booking-value-report.csv" => booking_value_report_csv
      },
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

  def generate_csv(data)
    CSV.generate(:encoding => 'utf-8') do |csv|
      data.each do |row|
        csv << row
      end
    end
  end

  def cash_report
    table = []
    totals = {
      'amount' => 0,
      'tax' => 0,
      'discount' => 0,
      'total' => 0
    }
    table << ['date', 'membership number', 'statement id', 'membership type', 'transaction type', 'coupon', 'amount', 'tax', 'discount', 'total']
    transactions = @transactions.group_by(&:subscription_id)
    transactions.keys.sort.each do |subscription_id|
      txns = transactions[subscription_id].group_by(&:type)
      vars = extract_identifiers(txns)
      charges =  txns['Charge'].group_by(&:kind)
      customer = @customers[vars[:customer_id]]
      product = @products[vars[:product_id]]
      totals['amount'] += charges['baseline'].first.amount_in_cents
      if charges['tax'].present?
        tax_amount = charges['tax'].first.amount_in_cents.to_i
        totals['tax'] += tax_amount
      else
        tax_amount = 0
      end
      totals['discount'] += vars[:discount]
      totals['total'] += vars[:total]
      row = [
        vars[:created_at].to_s(:db),
        customer.reference.to_s,
        vars[:statement_id].to_s,
        product.handle,
        "payment",
        vars[:coupon].to_s,
        "%d" % (charges['baseline'].first.amount_in_cents/100),
        "%d" % (tax_amount/100),
        "%d" % (vars[:discount]/100),
        "%d" % (vars[:total]/100)
      ]
      table << row
      if txns['Refund'].present?
        txns['Refund'].each { |refund| table << refund_row(refund, totals) }
      end
    end
    table << [
      "", "", "", "", "", "totals",
      (totals['amount']/100).to_s,
      (totals['tax']/100).to_s,
      (totals['discount']/100).to_s,
      (totals['total']/100).to_s
    ]
    return table
  end

  def refund_row(refund, totals)
    customer = @customers[refund.customer_id]
    product = @products[refund.product_id]
    txns = Chargify::Transaction.all(from: "/subscriptions/#{refund.subscription_id}/transactions").group_by(&:type) 
    payment = txns['Payment'].first
    charges = txns['Charge'].group_by(&:kind)
    if payment.amount_in_cents == refund.amount_in_cents
      totals['amount'] -= charges['baseline'].first.amount_in_cents
      totals['tax'] -= charges['tax'].first.amount_in_cents
      totals['total'] -= payment.amount_in_cents
      [
        refund.created_at.to_s(:db),
        customer.reference,
        refund.statement_id.to_s,
        product.handle,
        "refund",
        "",
        "-%d" % (charges['baseline'].first.amount_in_cents/100),
        "-%d" % (charges['tax'].first.amount_in_cents.to_i/100),
        "0",
        "-%d" % (payment.amount_in_cents.to_i/100)
      ]
    else
      totals['amount'] -= refund.amount_in_cents
      totals['total'] -= refund.amount_in_cents
      [
        refund.created_at.to_s(:db),
        customer.reference,
        refund.statement_id.to_s,
        product.handle,
        "refund",
        "",
        "-%d" % (refund.amount_in_cents.to_i/100),
        "0",
        "-%d" % (refund.amount_in_cents.to_i/100)
      ]
    end
  end

  def extract_identifiers(txns)
    obj = (txns['Payment'] || txns['Adjustment'] || txns['Charge']).first
    if obj.type == 'Adjustment'
      total = txns.values.flatten.select {|t| %w[Charge Adjustment].include?(t.type)}.sum(&:amount_in_cents)
      coupon_code = extract_coupon_code(obj)
      discount = obj.amount_in_cents
    else
      total = obj.amount_in_cents
      discount = 0
    end
    return {
      customer_id: obj.customer_id,
      product_id: obj.product_id,
      statement_id: obj.statement_id,
      created_at: obj.created_at,
      discount: discount,
      coupon: coupon_code,
      total: total
    }
  end

  def extract_coupon_code(txn)
    /Coupon: (.+) -/.match(txn.memo)[1]
  end

  def booking_value_report
    table = []
    table << ['product name', 'signup count', 'booking value', 'net', 'tax', 'total']
    @products.values.each do |product|
      count = @transactions.count { |txn| txn.type == 'Payment' && txn.product_id == product.id }
      amount = if product.handle =~ /monthly$/
        product.price_in_cents*12/100
      else
        product.price_in_cents/100
      end
      net = amount*count
      total, tax = 1.2*net, 0.2*net
      table << [product.handle, count.to_s, amount.to_i.to_s, net.to_i.to_s, tax.to_i.to_s, total.to_i.to_s]
    end
    table
  end
end
