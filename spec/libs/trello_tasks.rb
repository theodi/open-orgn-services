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
      {:id => "5343c1155004fb5959901ead", :title=>"One card", :due => "2014-04-10T11:00:00Z", :progress=>0.5, :no_checklist => false},
      {:id => "5343c118018736503833fff9", :title=>"Two cards", :due => nil, :progress=>0.0, :no_checklist => false},
      {:id => "5343c1213b73d9016dd28dfb", :title=>"Another card", :due => nil, :progress=>0.5, :no_checklist => false},
      {:id => "5343f80b97184a9b7c1c1d46", :title=>"No checklist!", :due => nil, :progress=>0, :no_checklist => true}
    ]

    completed = [
      {:id => "5343c18382c0f3c22cd8b1af", :title => "We've done this one", :due=>nil, :progress => 1.0, :no_checklist => false}
    ]

    discuss = [
      {:id => "5343c12e352a1bbf6cf5ef71", :title => "Let's have a chat about this one", :due => nil, :progress => 0.0, :no_checklist => false}
    ]

    metrics_api_should_receive("2014-q1-outstanding-tasks", time, outstanding.to_json)
    metrics_api_should_receive("2014-q1-completed-tasks", time, completed.to_json)
    metrics_api_should_receive("2014-q1-tasks-to-discuss", time, discuss.to_json)

    TrelloTasks.perform

    Timecop.return
  end

  it "should not choke on nil values" do
    allow(TrelloTasks).to receive(:board_ids).and_return({
        2014 => {
          :q1 => nil
        }
      })

    HTTParty.should_not_receive(:post)
    TrelloTasks.perform
  end

end
