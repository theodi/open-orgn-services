module CapsuleHelper

  def find_or_create_person(party)
    person = find_person(party['email'])
    if person.nil?
      first_name, last_name = party['name'].split(" ")
      person = CapsuleCRM::Person.new(
        first_name: first_name,
        last_name: last_name
      )
      person.emails << CapsuleCRM::Email.new(person, address: party['email'])
      person.save
    end
    person
  end

  def find_or_create_organization(party)
    org = find_organization(party['name'])
    if org.nil?
      org = CapsuleCRM::Organisation.new(
        name: party['name']
      )
      org.emails << CapsuleCRM::Email.new(org, address: party['email'])
      org.save
    end
    org
  end

  def find_organization(query)
    # Run fuzzy capsuleCRM match
    orgs = CapsuleCRM::Organisation.find_all(:q => query)
    # Find exact name or membership ID match
    orgs.find{|x| x.name.upcase == query.upcase || field(x, "Membership", "ID").try(:text) == query}
  end

  def find_person(query)
    CapsuleCRM::Person.find_all(:email => query).first
  end

  def find_org_by_membership_id(membership_id)
    parties = CapsuleCRM::Organisation.find_all(:q => membership_id)
    parties.find{|x| field(x, "Membership", "ID").try(:text) == membership_id}
  end

  def find_person_by_membership_id(membership_id)
    parties = CapsuleCRM::Person.find_all(:q => membership_id)
    parties.find{|x| field(x, "Membership", "ID").try(:text) == membership_id}
  end

  def set_membership_tag(party, fields)
    types = {
      "Level"                    => :text,
      "Supporter Level"          => :text,
      "ID"                       => :text,
      "Email"                    => :text,
      "Joined"                   => :date,
      "Newsletter"               => :boolean,
      "Share with third parties" => :boolean,
      "Size"                     => :text,
      "Sector"                   => :text,
      "Origin"                   => :text,
      "Contact first name"       => :text,
      "Contact last name"        => :text
    }
    set_custom_fields_on_tag(party, "Membership", fields, types)
  end

  def set_directory_entry_tag(party, fields)
    types = {
      'Active'        => :boolean,
      'Description'   => :text,
      'Description-2' => :text,
      'Description-3' => :text,
      'Description-4' => :text,
      'Homepage'      => :text,
      'Logo'          => :text,
      'Thumbnail'     => :text,
      'Contact'       => :text,
      'Phone'         => :text,
      'Email'         => :text,
      'Twitter'       => :text,
      'LinkedIn'      => :text,
      'Facebook'      => :text,
      'Tagline'       => :text,
    }
    set_custom_fields_on_tag(party, "DirectoryEntry", fields, types)
  end

  def set_custom_fields_on_tag(party, tag, fields, types)
    # Create data tag
    add_data_tag(party, tag)
    # Set custom fields
    success = true
    fields.each_pair do |label,value|
      next if value.nil?
      # Get data type and raise if not found
      data_type = types[label]
      raise ArgumentError.new("Unknown field label when setting #{tag} tag: #{label}. Is the label set in the set_membership_tag or set_directory_entry_tag array?") if data_type.nil?
      # Store field
      success &&= set_custom_field_on_tag(
        party,
        tag,
        :label    => label,
        data_type => value
      )
    end
    success
  end

  def add_data_tag(party, tag)
    tag = CapsuleCRM::Tag.new(
      party,
      :name => tag
    )
    save_item(tag)
    return CapsuleCRM::Base.last_response.code <= 201
  end

  def set_custom_field_on_tag(party, tag, data)
    custom_field = CapsuleCRM::CustomField.new(
      party,
      data.merge(:tag => tag)
    )
    save_item(custom_field)
    return CapsuleCRM::Base.last_response.code <= 201
  end

  def field(org, tag, field)
    org.custom_fields.find{|x| x.label == field && x.tag == tag}
  end

  def check_errors(obj)
    unless obj
      raise "Creating the #{obj} raised the following errors: #{obj.errors.join(', ')}"
    end
  end

  def save_item(obj)
    obj.save
    check_errors(obj)
  end

  def opportunity_closed?(opportunity)
    ["Invoiced", "Lost", "No project", "Contract Signed"].include?(opportunity.milestone)
  end

  def coverage_sectors
    [
      "Charity, Not-for-Profit",
      "Data & Information Services",
      "Education",
      "Finance",
      "FMCG",
      "Healthcare",
      "Professional Services",
      "Technology, Media, Telecommunications",
      "Transport, Construction, Engineering",
      "Utilities, Oil & Gas",
    ]
  end

end
