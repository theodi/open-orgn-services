def setup_trello
  VCR.use_cassette('trello_setup') do
    Trello::Authorization.const_set :AuthPolicy, Trello::Authorization::OAuthPolicy
    Trello::Authorization::OAuthPolicy.consumer_credential = Trello::Authorization::OAuthCredential.new ENV['TRELLO_DEV_KEY'], ENV['TRELLO_DEV_SECRET']
    Trello::Authorization::OAuthPolicy.token = Trello::Authorization::OAuthCredential.new ENV['TRELLO_MEMBER_KEY'], nil
  end
end

Given /^there are (\d+) cards on the (.*?) list on Trello$/ do |count, queue|
  setup_trello
  VCR.use_cassette("trello_check_#{queue}") do
    board = Trello::Board.find(ENV['TRELLO_CLEANUP_BOARD'])
    board.lists.find{|x| x.name == queue}.cards.count.should == count.to_i
  end
end

When /^the trello monitor runs$/ do
  VCR.use_cassette('trello_monitor') do
    TrelloMonitor.perform
  end
end