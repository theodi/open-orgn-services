def setup_trello
  Trello.configure do |config|
    config.developer_public_key = ENV['TRELLO_DEV_KEY']
    config.member_token = ENV['TRELLO_MEMBER_KEY']
  end
end

Given /^there are (\d+) cards on the (.*?) list on Trello$/ do |count, queue|
  setup_trello
  board = Trello::Board.find(ENV['TRELLO_CLEANUP_BOARD'])
  board.lists.find{|x| x.name == queue}.cards.count.should == count.to_i
end

When /^the trello monitor runs$/ do
  TrelloMonitor.perform
end