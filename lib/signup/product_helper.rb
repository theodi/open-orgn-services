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
    when :individual
      108
    when :student
      0
    else
      raise ArgumentError.new("Unknown product value #{product}")
    end
  end


  def product_duration(product)
    case product.to_sym
    when :individual
      1
    when :student
      1
    when :supporter
      12
    when :sponsor, :partner
      3
    else
      raise ArgumentError.new("Unknown product duration #{product}")
    end
  end

  def product_basis(product)
    case product.to_sym
    when :supporter
      'MONTH'
    when :sponsor, :partner, :individual, :student
      'YEAR'
    else
      raise ArgumentError.new("Unknown product basis #{product}")
    end
  end

end
