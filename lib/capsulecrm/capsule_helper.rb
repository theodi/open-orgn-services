module CapsuleHelper
  
  def find_organization(name)
    # Run fuzzy capsuleCRM match
    orgs = CapsuleCRM::Organisation.find_all(:q => name)
    # Find exact name match
    orgs.find{|x| x.name == name}
  end
  
  def set_membership_tag(party, fields)
    types = {
      "Level"      => :text,
      "ID"         => :text,
      "Email"      => :text,
      "Joined"     => :date,
      "Newsletter" => :boolean
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