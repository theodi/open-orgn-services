Then /^the number (\d+) should be stored in the (.*?) stat$/ do |number, stat|
  Resque.should_receive(:enqueue).with(LeftronicPublisher, :number, statistic_id(stat), number.to_i).once
  Resque.should_receive(:enqueue).any_number_of_times
end