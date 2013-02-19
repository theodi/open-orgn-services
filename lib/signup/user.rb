class User
  def initialize(user)
    @errors = {}
    
    if user[:contact_name].nil?
      @errors[:contact_name] = true
    end
  
    if user[:email].nil?
      @errors[:email] = true
    end

    if user[:address_line1].nil?
      @errors[:address_line1] = true
    end
    
    if user[:address_city].nil?
      @errors[:address_city] = true
    end

    if user[:address_country].nil?
      @errors[:address_country] = true
    end

    if user[:level].nil?
      @errors[:level] = true
    end
    
    if user[:agreed_to_terms] != true
      @errors[:agreed_to_terms] = true
    end
    
    if @errors.empty?
      Resque.enqueue(SignupProcessor, user)
    end
  end
  
  def errors
    return @errors
  end
end