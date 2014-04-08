require 'spec_helper'

describe TrelloTasks do

  it "should store right values in metrics API", :vcr do
    Timecop.freeze
    time = DateTime.now
    allow(TrelloTasks).to receive(:board_ids).and_return({
        2014 => {
          :q1 => "B5MnBDfR"
        }
      })

    outstanding = [
      {:title=>"One card", :due => "2014-04-10T11:00:00Z", :progress=>0.5, :no_checklist => false},
      {:title=>"Two cards", :due => nil, :progress=>0.0, :no_checklist => false},
      {:title=>"Another card", :due => nil, :progress=>0.5, :no_checklist => false},
      {:title=>"No checklist!", :due => nil, :progress=>0, :no_checklist => true}
    ]

    completed = [
      {:title => "We've done this one", :due=>nil, :progress => 1.0, :no_checklist => false}
    ]

    discuss = [
      {:title => "Let's have a chat about this one", :due => nil, :progress => 0.0, :no_checklist => false}
    ]

    metrics_api_should_receive("2014-q1-outstanding-tasks", time, outstanding.to_json)
    metrics_api_should_receive("2014-q1-completed-tasks", time, completed.to_json)
    metrics_api_should_receive("2014-q1-tasks-to-discuss", time, discuss.to_json)

    TrelloTasks.perform

    Timecop.return
  end

end
