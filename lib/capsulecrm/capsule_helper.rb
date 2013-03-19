module CapsuleHelper
  
  def organization_by_name(name)
    CapsuleCRM::Organisation.find_all(:q => name).first
  end
  
end