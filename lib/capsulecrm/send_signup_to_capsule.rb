class SendSignupToCapsule
  @queue = :signup

  extend ProductHelper
  extend CapsuleHelper

  def self.perform(party, membership)
    if %w(individual student).include?(membership['product_name'])
      p = find_or_create_person(party)
      first_name, last_name = party['name'].split(" ")
    else
      p = find_or_create_organization(party)
      first_name, last_name = party['contact_name'].split(" ")
    end

    # Create opportunity against organisation
    opportunity = CapsuleCRM::Opportunity.new(
      :party_id            => p.id,
      :name                => "Membership at #{membership['product_name']} level",
      :currency            => 'GBP',
      :description         => "Membership #: #{membership['id']}",
      :value               => product_value(membership['product_name']),
      :duration            => product_duration(membership['product_name']),
      :duration_basis      => product_basis(membership['product_name']),
      :milestone           => 'Invoiced',
      :probability         => 100,
      :expected_close_date => Date.parse(membership['join_date']),
      :owner               => ENV['CAPSULECRM_DEFAULT_OWNER'],
    )
    save_item(opportunity)

    # Write custom field for opportunity type
    field = CapsuleCRM::CustomField.new(
      opportunity,
      :label => 'Type',
      :text  => 'Membership'
    )
    save_item(field)

    set_membership_tag(
      p,
      "Level"                          => level(membership['product_name']),
      "Supporter Level"                => membership['supporter_level'],
      "ID"                             => membership['id'],
      "Joined"                         => Date.parse(membership['join_date']),
      "Email"                          => membership['contact_email'],
      "Twitter"                        => membership['twitter'],
      "Size"                           => membership['size'],
      "Sector"                         => membership['sector'],
      "Origin"                         => membership['origin'],
      "Coupon"                         => membership['coupon'],
      "Newsletter"                     => membership['newsletter'],
      "Share with third parties"       => membership['share_with_third_parties'],
      "Contact first name"             => first_name,
      "Contact last name"              => last_name,
      "DOB"                            => membership['dob'],
      "Country"                        => membership['country'],
      "University email"               => membership['university_email'],
      "University address country"     => membership['university_address_country'],
      "University country"             => membership['university_country'],
      "University name"                => membership['university_name'],
      "University name other"          => membership['university_name_other'],
      "University course name"         => membership['university_course_name'],
      "University qualification"       => membership['university_qualification'],
      "University qualification other" => membership['university_qualification_other'],
      "University course start"        => membership['university_course_start_date'],
      "University course end"          => membership['university_course_end_date']
    )

    unless membership['product_name'] == "individual"
      # Store company number on organization
      field = CapsuleCRM::CustomField.new(
        p,
        :label => 'Company Number',
        :text  => party['company_number'],
      )
      save_item(field)
    end
  end

  def self.level(product_name)
    case product_name
    when "student"
      "individual"
    else
      product_name
    end
  end
end
