require 'spec_helper'

describe PressMetrics do

  before :each do
    Timecop.freeze(Date.new(2014, 2, 4))
  end

  it "should store right values in metrics API" do
    # Which methods are called?
    PressMetrics.should_receive(:sentiment).once
    PressMetrics.should_receive(:spokespeople).once
    PressMetrics.should_receive(:sector_spread).once
    PressMetrics.should_receive(:geographical_spread).once
    PressMetrics.should_receive(:totals).once
    # How many metrics are stored?
    PressMetrics.should_receive(:store_metric).exactly(5).times
    # Do it
    PressMetrics.perform
  end

  it "should show the correct sentiment values", :vcr do
    PressMetrics.sentiment.should == {
      "positive" => 412,
      "neutral" => 15,
      "balanced" => 14,
      "negative" => 1
    }
  end

  it "should show the correct spokespeople", :vcr do
    PressMetrics.spokespeople.should == {
      "Tim Berners-Lee" => 18,
      "Nigel Shadbolt" => 16,
      "Gavin Starks" => 15,
      "Jeni Tennison" => 11,
      "Kathryn Corrick" => 6,
      "Emma Thwaites" => 4,
      "Ulrich Atz" => 3,
      "Richard Stirling" => 3,
      "Waldo Jaquith" => 3,
    }
  end

  it "should show the correct sector spread", :vcr do
    PressMetrics.sector_spread.should == {
      "Technology" => 332,
      "Government" => 328,
      "Corporate" => 136,
      "Cultural" => 53,
      "Financial" => 14,
      "Retail" => 5,
    }
  end

  it "should show the correct geographical spread", :vcr do
    PressMetrics.geographical_spread.should == {
      "UK" => 522,
      "Unspecified" => 88,
      "USA" => 53,
      "Canada" => 31,
      "Germany" => 9,
      "Italy" => 9,
      "Australia" => 6,
      "Singapore" => 4,
      "Belgium" => 3,
      "India" => 3,
      "France" => 2,
      "Africa" => 2,
      "Denmark" => 2,
      "Europe" => 1,
      "Brazil" => 1,
      "Austria" => 1,
      "Columbia" => 1,
      "Taiwan" => 1,
      "Nigeria" => 1,
      "Malaysia" => 1,
      "Malta" => 1,
    }
  end

  it "should show correct pr totals", :vcr do
    PressMetrics.totals.should == {
      "ODI" => {
        "volume" => 440,
        "value" => 1495674,
        "reach" => 57628683,
      },
      "OpenData" => {
        "volume" => 72,
        "value" => 417652,
        "reach" => 23181210,
      }
    }
  end

  after :each do
    Timecop.return
    PressMetrics.clear_cache!
  end

end
