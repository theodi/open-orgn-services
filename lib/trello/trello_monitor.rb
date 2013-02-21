require 'trello'

class TrelloMonitor

  @queue = :metrics
  
  def self.perform
    # Connect
    Trello.configure do |config|
      config.developer_public_key = ENV['TRELLO_DEV_KEY']
      config.member_token = ENV['TRELLO_MEMBER_KEY']
    end
    # Trello todo/doing queues
    board = Trello::Board.find(ENV['TRELLO_CLEANUP_BOARD'])
    todo = board.lists.find{|x| x.name == "To Do"}.cards.count
    doing = board.lists.find{|x| x.name == "Doing"}.cards.count
    # Publish
    Resque.enqueue LeftronicPublisher, :number, ENV['LEFTRONIC_TRELLO_COUNT'], todo + doing # straight number
    Resque.enqueue LeftronicPublisher, :number, ENV['LEFTRONIC_TRELLO_LINE'], todo + doing # sparkline  
  end
  
end