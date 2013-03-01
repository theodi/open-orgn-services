class PartnerEnquiryProcessor
  @queue = :signup
  
  # Public: Process new enquiries
  #
  # person  - a hash containing details of the person sending the enquiry.
  #           'name'           => the name of the enquirer
  #           'affiliation'    => the person's organisation
  #           'job_title'      => role
  #           'email'          => email address
  #           'telephone'      => phone number
  # 
  # product - a hash describing the product being enquired about
  #           'name'           => textual name of membership level they have expressed an interest in
  # 
  # comment - a hash describing the comment submitted in the contact form
  #           'text'           => the text content of the comment
  #
  # Returns nil. Queues CRM task creation jobs.
  def self.perform(person, product, comment)
    # Create organisation in CapsuleCRM
    organisation = CapsuleCRM::Organisation.find_all(:q => person['affiliation']).first
    if organisation.nil?
      organisation = CapsuleCRM::Organisation.new(:name => person['affiliation'])
      organisation.save
    end
    # Create person
    person = CapsuleCRM::Person.new(
      :organisation_id => organisation.id,
      :first_name => person['name'].split(' ', 1)[0],
      :last_name => person['name'].split(' ', 1)[1],
      :job_title => person['job_title'],
    )
    person.save
  end
  
end