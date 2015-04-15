When(/^the gdrive mover job runs$/) do
  GoogleDrive::Mover.perform
end

Given(/^the aggregate spreadsheet has (\d+) worksheets?$/) do |worksheets_size|
  GoogleDrive::Mover.aggregate.worksheets.size.should ==  worksheets_size
end

Then(/^the aggregate spreadsheet should have (\d+) worksheets$/) do |worksheets_size|
  step "the aggregate spreadsheet has #{worksheets_size} worksheets"
end

Given(/^there [^\s]+ (\d+) spreadsheets? in the spool$/) do |collection_size|
  step "there should be #{collection_size} spreadsheets in the spool"
end

Then(/^there should be (\d+) spreadsheets? in the target$/) do |collection_size|
  GoogleDrive::Mover.target.files.size.should == collection_size.to_i
end

Then(/^there should be (\d+) spreadsheets? in the spool$/) do |collection_size|
  GoogleDrive::Mover.spool.files.size.should == collection_size.to_i
end

Then(/^the new worksheet should match the moved spreadsheet content$/) do
  files = GoogleDrive::Mover.target.files
  first = files.first
  last = files.last

  first.worksheets.last.rows.should == last.worksheets.last.rows
end
