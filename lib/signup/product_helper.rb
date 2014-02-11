module ProductHelper

  def products
    [
      :supporter,
      :member,
      :sponsor,
      :partner
    ]
  end

  def product_value(product)
    case product.to_sym
    when :supporter
      60
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
    when :supporter
      12
    when :sponsor, :partner
      3
    else
      raise ArgumentError.new("Unknown product name #{product}")
    end
  end
    
  def product_basis(product)
    case product.to_sym
    when :supporter
      'MONTH'
    when :sponsor, :partner
      'YEAR'
    else
      raise ArgumentError.new("Unknown product name #{product}")
    end
  end

end