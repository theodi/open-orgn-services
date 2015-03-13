require 'chargify_api_ares'

class ReportGenerator
  @queue = :directory

  def initialize(start_date, end_date)
    @start_date, @end_date = start_date, end_date
  end

  def send_report(email)
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

  def cash_report
    table = []
    totals = {
      'amount' => 0,
      'tax' => 0,
      'total' => 0
    }
    table << ['date', 'membership number', 'statement id', 'membership type', 'transaction type', 'amount', 'tax', 'total']
    transactions = @transactions.group_by(&:subscription_id)
    transactions.keys.sort.each do |subscription_id|
      txns = transactions[subscription_id].group_by(&:type)
      payment = txns['Payment'].first
      charges =  txns['Charge'].group_by(&:kind)
      customer = @customers[payment.customer_id]
      product = @products[payment.product_id]
      totals['amount'] += charges['baseline'].first.amount_in_cents
      totals['tax'] += charges['tax'].first.amount_in_cents
      totals['total'] += payment.amount_in_cents
      row = [
        payment.created_at.to_s(:db),
        customer.reference,
        payment.statement_id.to_s,
        product.handle,
        "payment",
        "%d" % (charges['baseline'].first.amount_in_cents/100),
        "%d" % (charges['tax'].first.amount_in_cents.to_i/100),
        "%d" % (payment.amount_in_cents.to_i/100)
      ]
      table << row
      if txns['Refund'].present?
        txns['Refund'].each { |refund| table << refund_row(refund, totals) }
      end
    end
    table << [
      "", "", "", "", "totals",
      (totals['amount']/100).to_s,
      (totals['tax']/100).to_s,
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
        "-%d" % (charges['baseline'].first.amount_in_cents/100),
        "-%d" % (charges['tax'].first.amount_in_cents.to_i/100),
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
        "-%d" % (refund.amount_in_cents.to_i/100),
        "0",
        "-%d" % (refund.amount_in_cents.to_i/100)
      ]
    end
  end

  def booking_value_report
  end
end
