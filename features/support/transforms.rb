INTEGER = Transform /^\d+$/ do |number|
  number.to_i
end

FLOAT = Transform /^\d+\.\d+$/ do |number|
  number.to_f
end

DATE = Transform /^(\d+)\-(\d+)\-(\d+)$/ do |year, month, day|
  Date.new(year.to_i, month.to_i, day.to_i)
end