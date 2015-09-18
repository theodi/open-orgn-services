class CapsuleMembers
  include CapsuleHelper

  def self.all
    new.all
  end

  def all
    organizations + people
  end

  def organizations
    CapsuleCRM::Organisation.find_all(:tag => "Membership")
  end

  def people
    CapsuleCRM::Person.find_all(:tag => "Membership")
  end
end

