require 'trello'

class QuarterlyProgress
  @queue = :metrics

  extend MetricsHelper

  def self.perform
    h = {
        '2014' => progress(2014),
        '2013' => progress(2013)
    }
    store_metric("quarterly-progress", DateTime.now, h)
  end

  def self.progress(year)

    year = year.to_i

    board_ids = {
        2013 => {
            :q1 => 'cEwY2JHh',
            :q2 => 'm5Gxybf6',
            :q3 => 'wkIzhRE3',
            :q4 => '5IZH6yGG',
        },
        2014 => {
            :q1 => '8P2Hgzlh',
            :q2 => 'sFETRDq0',
            :q3 => nil,
            :q4 => nil,
        },
    }

    totals = {}

    board_ids[year].each do |q, id|
      progress = get_board_progress(id)
      if progress.empty?
        totals[q] = 0
      else
        totals[q] = (100 * (progress.inject { |sum, element| sum += element } / progress.size)).round(1)
      end
    end

    totals
  end

  def self.get_board_progress(id)
    Trello.configure do |config|
      config.developer_public_key = ENV['TRELLO_DEV_KEY']
      config.member_token         = ENV['TRELLO_MEMBER_KEY']
    end

    return [] if id.nil?

    progress = []
    board    = Trello::Board.find(id)

    board.cards.each do |card|
      card.checklists.each do |checklist|
        total = checklist.check_items.count
        unless total == 0
          complete      = checklist.check_items.select { |item| item["state"]=="complete" }.count
          task_progress = complete.to_f/total.to_f
          progress << task_progress
        end
      end
    end

    progress
  end
end
