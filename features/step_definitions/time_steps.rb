Given /^that it's (#{DATETIME})$/ do |datetime|
  Timecop.freeze(datetime)
end

Given /^that it's (#{INTEGER}) hours into the future$/ do |num|
  Timecop.freeze(DateTime.now + num.hours)
end