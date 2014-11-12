require 'spec_helper'

describe NetworkMetrics do

  before :each do
    Timecop.freeze(Date.new(2014, 2, 4))
  end

  it "should store right values in metrics API" do
    # Which methods are called?
    NetworkMetrics.should_receive(:reach).with(2014).once
    NetworkMetrics.should_receive(:reach).with(nil).once
    NetworkMetrics.should_receive(:pr_pieces).with(2014).once
    NetworkMetrics.should_receive(:events_hosted).with(2014).once
    NetworkMetrics.should_receive(:people_trained).with(2014, 2).once
    NetworkMetrics.should_receive(:people_trained).with(nil, nil).once
    NetworkMetrics.should_receive(:network_size).with(2014, 2).once
    NetworkMetrics.should_receive(:network_size).with(nil, nil).once
    # How many metrics are stored?
    NetworkMetrics.should_receive(:store_metric).exactly(8).times
    # Do it
    NetworkMetrics.perform
  end

  it "should show the correct cumulative reach", :vcr do
    NetworkMetrics.reach.should == {
      :total   => 639817,
      :breakdown => {
        :active  => 20538,
        :passive => 619279,
      }
    }
  end

  it "should show the correct reach for 2013", :vcr do
    NetworkMetrics.reach(2013).should == {
      :total   => 303396,
      :breakdown => {
        :active  => 10526,
        :passive => 292870,
      }
    }
  end

  it "should show the correct reach for 2014", :vcr do
    NetworkMetrics.reach(2014).should == {
      :total   => 336421,
      :breakdown => {
        :active  => 10012,
        :passive => 326409,
      }
    }
  end

  it "should show the correct number of PR pieces", :vcr do
    NetworkMetrics.pr_pieces(2014).should == 99
  end

  it "should show the correct number of events hosted", :vcr do
    NetworkMetrics.events_hosted(2014).should == 2
  end

  it "should show number of people trained", :vcr do
    NetworkMetrics.people_trained(2014, 2).should == {
        commercial:     {
            actual:        34,
            annual_target: 190,
            ytd_target:    25,
        },
        non_commercial: {
            actual:        41,
            annual_target: 206,
            ytd_target:    26,
        }
    }
  end

  it "should show the cumulative number of people trained", :vcr do
    NetworkMetrics.people_trained(nil, nil).should == 309
  end

  it "should show correct network size", :vcr do
    NetworkMetrics.network_size(2014, 2).should == {
        partners:   {
            actual:        3,
            annual_target: 10,
            ytd_target:    2,
        },
        sponsors:   {
            actual:        1,
            annual_target: 5,
            ytd_target:    0,
        },
        supporters: {
            actual:        7,
            annual_target: 34,
            ytd_target:    2,
        },
        startups:   {
            actual:        7,
            annual_target: 6,
            ytd_target:    6,
        },
        nodes:      {
            actual:        11,
            annual_target: 20,
            ytd_target:    0,
        },
        affiliates: {
            actual:        0,
        }
    }
  end

  it "should show the cumulative network size", :vcr do
    NetworkMetrics.network_size(nil, nil).should == 103
  end

  after :each do
    Timecop.return
    NetworkMetrics.clear_cache!
  end

end
