def statistic_id(stat_name)
  ids = {
    'public repositories' => 'LEFTRONIC_GITHUB_REPOS',
    'open issues' => 'LEFTRONIC_GITHUB_ISSUES',
    'watchers' => 'LEFTRONIC_GITHUB_WATCHERS',
    'forks' => 'LEFTRONIC_GITHUB_FORKS',
    'open pull requests' => 'LEFTRONIC_GITHUB_OPENPRS',
    'total pull requests' => 'LEFTRONIC_GITHUB_PULLS',
    'housekeeping graph' => 'LEFTRONIC_TRELLO_LINE',
  }
  if ids[stat_name]
    ENV[ids[stat_name]]
  else
    raise ArgumentError.new("Unknown stat #{stat_name}")
  end
end

Then /^the number (\d+) should be stored in the (.*?) stat$/ do |number, stat|
  Resque.should_receive(:enqueue).with(LeftronicPublisher, :number, statistic_id(stat), number.to_i).once
  Resque.should_receive(:enqueue).any_number_of_times
end