module SignupProcessorSupport

  def create_signup_processor_membership_hash
    @membership = { :description => "ODI " + @level + " membership " + @company.nil? ? "for " + @company : ( @firstname && @lastname ? "for " + @firstname + @lastname : "" ) }
  end

end

World(SignupProcessorSupport)