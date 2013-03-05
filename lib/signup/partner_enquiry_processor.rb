require 'pry'

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
    # Find existing contact for this organisation in CapsuleCRM
    contact = organisation.people.find do |p| 
      [p.first_name, p.last_name].compact.join(' ') == person['name']
    end
    # If there is no contact, create a new one
    if contact.nil?
      contact = CapsuleCRM::Person.new(
        :organisation_id => organisation.id,
        :first_name => person['name'].split(' ', 2)[0],
        :last_name => person['name'].split(' ', 2)[1],
      )
    end
    # Update contact with new details
    contact.job_title = person['job_title']
    contact.emails << CapsuleCRM::Email.new(contact, :type => "Work", :address => person['email'])
    contact.phone_numbers << CapsuleCRM::Phone.new(contact, :type => "Work", :number => person['telephone'])
    contact.contacts_will_change! # We have to mark this manually for now
    contact.save
    # Create opportunity for organisation
    opportunity = CapsuleCRM::Opportunity.new(
      :party_id => organisation.id, 
      :name => "Membership at #{product['name']} level",
      :currency => 'GBP',
      :description => comment['text'],
      :value => value_for_product_name(product['name']),
      :duration => 3,
      :duration_basis => 'YEAR',
      :milestone => 'New',
      :probability => 10,
    )
    opportunity.save
  end
  
  def self.value_for_product_name(product)
    case product.to_sym
    when :sponsor
      25000
    when :partner
      50000
    else
      raise ArgumentError.new("Unknown product name #{product}")
    end
  end
  
end