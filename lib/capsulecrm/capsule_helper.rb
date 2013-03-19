module CapsuleHelper
  
  def organization_by_name(name)
    CapsuleCRM::Organisation.find_all(:q => name).first
  end
  
  def set_membership_tag(party, fields)
    # Create membership tag
    tag = CapsuleCRM::Tag.new(
      party,
      :name => 'Membership'
    )
    tag.save
    # Set custom fields
    types = {
      "Level"  => :text,
      "ID"     => :text,
      "Email"  => :text,
      "Joined" => :date
    }
    fields.each_pair do |label,value|
      set_custom_field_on_tag(
        party, 
        "Membership",
        :label => label,
        types[label] => value
      )
    end
  end

  def set_custom_field_on_tag(party, tag, data)
    custom_field = CapsuleCRM::CustomField.new(
      party,
      data.merge(:tag => tag)
    )
    custom_field.save
  end


end