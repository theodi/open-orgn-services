module CapsuleHelper

  def find_organization(query)
    # Run fuzzy capsuleCRM match
    orgs = CapsuleCRM::Organisation.find_all(:q => query)
    # Find exact name or membership ID match
    orgs.find{|x| x.name == query || field(x, "Membership", "ID").try(:text) == query}
  end

  def set_membership_tag(party, fields)
    types = {
      "Level"           => :text,
      "Supporter Level" => :text,
      "ID"              => :text,
      "Email"           => :text,
      "Joined"          => :date,
      "Newsletter"      => :boolean,
      "Size"            => :text,
      "Sector"          => :text,
    }
    set_custom_fields_on_tag(party, "Membership", fields, types)
  end

  def set_directory_entry_tag(party, fields)
    types = {
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
