Given /^that it's (#{DATETIME})$/ do |datetime|
  Timecop.freeze(datetime)
end