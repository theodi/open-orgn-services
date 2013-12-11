module MembershipHelper
  
  def membership_length
    {
      "sponsor"   => 3.years,
      "partner"   => 3.years,
      "member"    => 1.year,
      "supporter" => 1.year
    }
  end
  
end