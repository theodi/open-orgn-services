class PartnerEnquiryProcessor
  @queue = :signup
  
  # Public: Process new enquiries
  #
  # enquiry_details - a hash containing details of the enquiry.
  #                   'name'           => the name of the enquirer
  #                   'affiliation'    => the person's organisation
  #                   'job_title'      => role
  #                   'email'          => email address
  #                   'telephone'      => phone number
  #                   'offer_category' => the membership level they have expressed an interest in
  #                   'note'           => free text, 'what would you like to talk about'
  #
  # Examples
  #
  #   SignupProcessor.perform({:name => 'Bob Fish', :affiliation => 'New Company Inc.', ...})
  #   # => nil
  #
  # Returns nil. Queues CRM task creation jobs.
  def self.perform(enquiry_details)
  end
  
end