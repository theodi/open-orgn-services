Before("@record_all_cassettes") do
  VCR.configure do |c|
    c.default_cassette_options = {:record => :all}
  end
end

After("@record_all_cassettes") do
  VCR.configure do |c|
    c.default_cassette_options = {:record => :new_episodes}
  end
end

After("@clean_up_xero_contact") do
  if @contact
    @contact.name = [@contact.name, @contact.id].join(' ')
    @contact.save
  end
end

After do
  if @invoice
    @invoice.delete!
  end
  # Clear up after multiple invoices are created
  if @invoices
    @invoices.each do |invoice|
      invoice.delete!
    end
  end
end