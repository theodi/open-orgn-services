After("@timecop") do
  Timecop.return
end

After("@clean_up_xero_contact") do
  if @contact
    @contact.name = [@contact.name, @contact.id].join(' ')
    @contact.save
  end
end

Before("@capsulecrm") do
  @capsule_cleanup = []
end

After("@capsulecrm") do
  @capsule_cleanup.each do |x|
    x.delete!
  end
end

After("@clean_up_xero_invoice") do
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

Before("@mailchimp") do
  @mailchimp_cleanup = []
end

After("@mailchimp") do
  MailchimpCleaner.clean!(@mailchimp_cleanup)
end

