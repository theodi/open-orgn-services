module XeroSupport  

  # Shared setup for the Xero connection

  def xero
    @xero ||= Xeroizer::PrivateApplication.new(
      ENV["XERO_CONSUMER_KEY"],
      ENV["XERO_CONSUMER_SECRET"],
      ENV["XERO_PRIVATE_KEY_PATH"],
      :rate_limit_sleep => 5
    )
  end
  
end

World(XeroSupport)