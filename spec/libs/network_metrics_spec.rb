require 'spec_helper'

describe NetworkMetrics do

  before :each do
    Timecop.freeze(Date.new(2014, 2, 4))
  end

  it "should store right values in metrics API" do
    WebMock.allow_net_connect!
    time = DateTime.now
    {
      "current-year-reach"                   => '{"total":70100,"breakdown":{"active":100,"passive":70000}}',
      "cumulative-reach"                     => '{"total":373496,"breakdown":{"active":10626,"passive":362870}}',
      "current-year-pr-pieces"               => 0,
      "cumulative-people-trained"            => 234,
      "current-year-people-trained"          => '{"commercial":{"actual":36,"annual_target":190,"ytd_target":25},"non_commercial":{"actual":55,"annual_target":206,"ytd_target":26}}',
      "current-year-network-size"            => '{"partners":{"actual":3,"annual_target":10,"ytd_target":2},"sponsors":{"actual":1,"annual_target":5,"ytd_target":0},"supporters":{"actual":7,"annual_target":34,"ytd_target":2},"startups":{"actual":7,"annual_target":6,"ytd_target":6},"nodes":{"actual":11,"annual_target":20,"ytd_target":0},"affiliates":{"actual":0}}',
      "cumulative-network-size"              => 80
    }.each_pair do |metric, value|
      metrics_api_should_receive metric, time, value
    end

    NetworkMetrics.perform
    Timecop.return
    WebMock.disable_net_connect!
  end

  it "should show the correct cumulative reach", :vcr do
    NetworkMetrics.reach.should == {
      :total   => 373496,
      :breakdown => {
        :active  => 10626,
        :passive => 362870,
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
      :total   => 70100,
      :breakdown => {
        :active  => 100,
        :passive => 70000,
      }
    }
  end

  it "should show the correct number of PR pieces", :vcr do
    NetworkMetrics.pr_pieces(2014).should == 0
  end

  it "should show number of people trained", :vcr do
    NetworkMetrics.people_trained(2014, 2).should == {
        commercial:     {
            actual:        36,
            annual_target: 190,
            ytd_target:    25,
        },
        non_commercial: {
            actual:        55,
            annual_target: 206,
            ytd_target:    26,
        }
    }
  end
  
  it "should show the cumulative number of people trained", :vcr do
    NetworkMetrics.people_trained(nil, nil).should == 234
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
    NetworkMetrics.network_size(nil, nil).should == 80
  end

  after :each do
    Timecop.return
    NetworkMetrics.clear_cache!
  end

end