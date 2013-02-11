require 'trello'

def TrelloMonitor
  @queue = :metrics
  
  def self.perform
    # Connect
    Trello::Authorization.const_set :AuthPolicy, Trello::Authorization::OAuthPolicy
    Trello::Authorization::OAuthPolicy.consumer_credential = Trello::Authorization::OAuthCredential.new ENV['TRELLO_DEV_KEY'], ENV['TRELLO_DEV_SECRET']
    Trello::Authorization::OAuthPolicy.token = Trello::Authorization::OAuthCredential.new ENV['TRELLO_MEMBER_KEY'], nil
    # Trello todo/doing queues
    board = Trello::Board.find(ENV['TRELLO_CLEANUP_BOARD'])
    todo = board.lists.find{|x| x.name == "To Do"}.cards.count
    doing = board.lists.find{|x| x.name == "Doing"}.cards.count
    # Publish
    Resqueue.enqueue LeftronicPublisher, :number, ENV['LEFTRONIC_TRELLO_COUNT'], todo + doing # straight number
    Resqueue.enqueue LeftronicPublisher, :number, ENV['LEFTRONIC_TRELLO_LINE'], todo + doing # sparkline  
  end
  
end