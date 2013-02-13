Before do |scenario|
  # Store name for use in cassettes
  @scenario_name = scenario.name
end


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
    VCR.use_cassette("#{@scenario_name}/rename_contact") do
      @contact.save
    end
  end
end

After do
  if @invoice
    VCR.use_cassette("#{@scenario_name}/delete_invoice") do
      @invoice.delete!
    end
  end
end