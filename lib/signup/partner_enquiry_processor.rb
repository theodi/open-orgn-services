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
    @org = CapsuleCRM::Organisation.new(:name => person['affiliation'])
    @org.save
  end
  
end