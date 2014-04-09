class TrelloTasks
  @queue = :metrics

  extend MetricsHelper
  extend TrelloBoards

  def self.perform
    board_ids.each do |year,hash|
      hash.each do |quarter,board_id|
        next if board_id.nil?
        board = TrelloBoard.new(board_id)
        store_metric("#{year}-#{quarter}-outstanding-tasks", DateTime.now, board.outstanding)
        store_metric("#{year}-#{quarter}-completed-tasks", DateTime.now, board.done)
        store_metric("#{year}-#{quarter}-tasks-to-discuss", DateTime.now, board.to_discuss)
      end
    end
  end

end
