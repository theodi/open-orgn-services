require 'spec_helper'

describe TrelloBoard do

  before(:all) do
    VCR.use_cassette('Progress/progress_spec') do
      @board = TrelloBoard.new("B5MnBDfR")
    end
  end

  it "returns the correct outstanding cards", :vcr do
    outstanding = @board.outstanding
    outstanding.count.should == 4
    outstanding[0].should == {:id => "5343c1155004fb5959901ead", :title=>"One card", :due => DateTime.parse("2014-04-10 11:00:00 UTC"), :progress=>0.5, :no_checklist => false}
    outstanding[1].should == {:id => "5343c118018736503833fff9", :title=>"Two cards", :due => nil, :progress=>0.0, :no_checklist => false}
    outstanding[2].should == {:id => "5343c1213b73d9016dd28dfb", :title=>"Another card", :due => nil, :progress=>0.5, :no_checklist => false}
    outstanding[3].should == {:id => "5343f80b97184a9b7c1c1d46", :title=>"No checklist!", :due => nil, :progress=>0, :no_checklist => true}
  end

  it "returns the correct to discuss cards", :vcr do
    to_discuss = @board.to_discuss
    to_discuss.count.should == 1
    to_discuss[0].should == {:id => "5343c12e352a1bbf6cf5ef71", :title => "Let's have a chat about this one", :due => nil, :progress => 0.0, :no_checklist => false}
  end

  it "returns the correct done cards", :vcr do
    done = @board.done
    done.count.should == 1
    done[0].should == {:id => "5343c18382c0f3c22cd8b1af", :title => "We've done this one", :due=>nil, :progress => 1.0, :no_checklist => false}
  end

  it "returns the correct ID of the 'to discuss' list", :vcr do
    @board.discuss_list.should == "5343be8b0876eb6e19c59baa"
  end

  it "returns the correct progress for a card" do
    checklist = double("Trello::Checklist", check_items: [
        {
          "name" => "Do this thing",
          "state" => "complete"
        },
        {
          "name" => "Do that thing",
          "state" => "Incomplete"
        }
      ])

    card = double("Trello::Card", id: "some-fake-id", checklists: [checklist], due: nil, name: "This is a card")
    @board.send(:get_progress, card).should == { id: "some-fake-id", title: "This is a card", :due => nil, progress: 0.5, :no_checklist => false }
  end

  it "returns the correct progress for a card with multiple checklists" do
    checklists = [
        double("Trello::Checklist", check_items: [
          {
            "name" => "Do this thing",
            "state" => "complete"
          },
          {
            "name" => "Do that thing",
            "state" => "Incomplete"
          }
        ]),
        double("Trello::Checklist", check_items: [
          {
            "name" => "Do this thing",
            "state" => "complete"
          },
          {
            "name" => "Do that thing",
            "state" => "complete"
          }
        ])
      ]

    card = double("Trello::Card", id: "some-fake-id", checklists: checklists, due: nil, name: "This is a card")
    @board.send(:get_progress, card).should == { id: "some-fake-id", title: "This is a card", :due => nil, progress: 0.75, :no_checklist => false }
  end

  it "returns a warning if there is no checklist" do
    card = double("Trello::Card", id: "some-fake-id", checklists: [], due: nil, name: "This is a card")
    @board.send(:get_progress, card).should == { id: "some-fake-id", title: "This is a card", :due => nil, progress: 0, :no_checklist => true }
  end

end
