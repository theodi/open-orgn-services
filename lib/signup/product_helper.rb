module ProductHelper

  def product_value(product)
    case product.to_sym
    when :supporter
      45
    when :member
      400
    when :sponsor
      25000
    when :partner
      50000
    else
      raise ArgumentError.new("Unknown product name #{product}")
    end
  end
  
  
  def product_duration(product)
    case product.to_sym
    when :supporter, :member
      12
    when :sponsor, :partner
      3
    else
      raise ArgumentError.new("Unknown product name #{product}")
    end
  end
    
  def product_basis(product)
    case product.to_sym
    when :supporter, :member
      'MONTH'
    when :sponsor, :partner
      'YEAR'
    else
      raise ArgumentError.new("Unknown product name #{product}")
    end
  end

end