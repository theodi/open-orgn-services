module CapsuleHelper
  
  def organization_by_name(name)
    orgs = CapsuleCRM::Organisation.find_all(:q => name)
    orgs.length == 1 ? orgs.first : nil
  end
  
  def set_membership_tag(party, fields)
    # Create membership tag
    add_data_tag(party, "Membership")
    # Set custom fields
    types = {
      "Level"  => :text,
      "ID"     => :text,
      "Email"  => :text,
      "Joined" => :date
    }
    set_custom_fields_on_tag(party, "Membership", fields, types)
  end

  def set_directory_entry_tag(party, fields)
    # Create directory entry tag
    add_data_tag(party, "DirectoryEntry")
    # Set custom fields
    types = {
      'Description' => :text,
      'Homepage'    => :text,
      'Logo'        => :text,
      'Thumbnail'   => :text,
      'Contact'     => :text,
      'Phone'       => :text,
      'Email'       => :text,
      'Twitter'     => :text,
      'LinkedIn'    => :text,
      'Facebook'    => :text,
    }
    set_custom_fields_on_tag(party, "DirectoryEntry", fields, types)
  end
  
  def set_custom_fields_on_tag(party, tag, fields, types)
    success = true
    fields.each_pair do |label,value|
      # Get data type and raise if not found
      data_type = types[label]
      raise ArgumentError.new("Unknown field label when setting #{tag} tag: #{label}") if data_type.nil?
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
    tag.save
    return CapsuleCRM::Base.last_response.code <= 201
  end

  def set_custom_field_on_tag(party, tag, data)
    custom_field = CapsuleCRM::CustomField.new(
      party,
      data.merge(:tag => tag)
    )
    custom_field.save
    return CapsuleCRM::Base.last_response.code <= 201
  end


end