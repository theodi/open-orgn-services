After("@clean_up_xero_contact") do |scenario|
  if @contact
    @contact.name = [@contact.name, @contact.id].join(' ')
    VCR.use_cassette("rename_contact_#{scenario.name}") do
      @contact.save
    end
  end
end