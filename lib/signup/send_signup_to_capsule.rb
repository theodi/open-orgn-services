require 'pry'

class SendSignupToCapsule
  @queue = :signup
  
  # Public: Store details of self-signups in CapsuleCRM
  #
  # membership   - a hash containing details of the new membership
  #              'product_name' => the membership level
  #              'id'           => the newly-generated membership number
  #              'join_date'    => the date of signup
  # 
  # organization - a hash containing details of the organization
  #              'name' => the org name in Xero - should be the same as that in capsule
  # 
  # Returns nil.
  def self.perform(organization, membership)
    organisation = CapsuleCRM::Organisation.find_all(:q => organization['name']).first
    if organisation.nil?
      Resque.enqueue_in(1.hour, SendSignupToCapsule, organization, membership)
    else
      # Create opportunity against organisation
      opportunity = CapsuleCRM::Opportunity.new(
        :party_id => organisation.id, 
        :name => "Membership at #{membership['product_name']} level",
        :currency => 'GBP',
        :description => "Membership #: #{membership['id']}",
        :value => value_for_product_name(membership['product_name']),
        :duration => 12,
        :duration_basis => 'MONTH',
        :milestone => 'Won',
        :probability => 100,
        :expected_close_date => Date.parse(membership['join_date']),
        :owner => ENV['CAPSULECRM_DEFAULT_OWNER'],
      )
      opportunity.save
      # Write custom field for opportunity type
      field = CapsuleCRM::CustomField.new(
        opportunity,
        :label => 'Type',
        :text => 'Membership'
      )
      field.save
      # Create data tag on organisation
      tag = CapsuleCRM::Tag.new(
        organisation,
        :name => 'Membership'
      )
      tag.save
      # Set custom fields (in data tag)
      # Currently we have code to do these individually, so let's do that. Collections may come later.
      # Membership level
      field = CapsuleCRM::CustomField.new(
        organisation,
        :tag => 'Membership',
        :label => 'Level',
        :text => membership['product_name'],
      )
      field.save
      # Membership number
      field = CapsuleCRM::CustomField.new(
        organisation,
        :tag => 'Membership',
        :label => 'ID',
        :text => membership['id'],
      )
      field.save
      # Membership number
      field = CapsuleCRM::CustomField.new(
        organisation,
        :tag => 'Membership',
        :label => 'Joined',
        :date => Date.parse(membership['join_date']),
      )
      field.save  
    end
  end
  
  def self.value_for_product_name(product)
    case product.to_sym
    when :supporter
      45
    when :member
      400
    else
      raise ArgumentError.new("Unknown product name #{product}")
    end
  end

end