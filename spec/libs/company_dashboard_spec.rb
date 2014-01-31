require 'spec_helper'

describe CompanyDashboard do

  it "should store right values in metrics API", :vcr do
    Timecop.freeze
    time = DateTime.now
    metrics_api_should_receive("current-year-reach", time, 775655)
    metrics_api_should_receive("cumulative-reach", time, 1079051)
    metrics_api_should_receive("current-year-active-reach", time, 432423)
    metrics_api_should_receive("current-year-passive-reach", time, 343232)
    metrics_api_should_receive("current-year-bookings", time, 0)
    metrics_api_should_receive("cumulative-bookings", time, 2191064)
    metrics_api_should_receive("current-year-value-unlocked", time, 775655)
    metrics_api_should_receive("cumulative-value-unlocked", time, 17699962)
    metrics_api_should_receive("current-year-commercial-bookings", time, '{"actual": 78.0,"target": 874.48}')
    metrics_api_should_receive("current-year-non-commercial-bookings", time, '{"actual": 156.0,"target": 45.2}')
    metrics_api_should_receive("current-year-kpi-performance", time, 1.0)
    metrics_api_should_receive("current-year-grant-funding", time, '{"actual": 3040.00,"target": 3354.6176046176}')
    metrics_api_should_receive("current-year-income-by-type", time, '{"research": 900.00,"training": 289.00,"projects": 900.00,"network": 912.00}')
    metrics_api_should_receive("current-year-income-by-sector", time, "{\"research\":{\"commercial\":{\"actual\":890.0,\"target\":1500.0},\"non_commercial\":{\"actual\":423.0,\"target\":750.0}},\"training\":{\"commercial\":{\"actual\":87.0,\"target\":128.12},\"non_commercial\":{\"actual\":121.0,\"target\":180.78}},\"projects\":{\"commercial\":{\"actual\":123.0,\"target\":450.0},\"non_commercial\":{\"actual\":212.0,\"target\":500.0}},\"network\":{\"commercial\":{\"actual\":78.0,\"target\":874.48},\"non_commercial\":{\"actual\":156.0,\"target\":45.2}}}")      
    metrics_api_should_receive("current-year-headcount", time, '{"actual": 22.0,"target": 22.0}')      
    metrics_api_should_receive("current-year-burn", time, '{"actual": 320.0,"target": 314.766666666667}')      
    CompanyDashboard.perform
    Timecop.return
  end

  it "should show the correct reach", :vcr do
    CompanyDashboard.reach.should == 1079051
  end
  
  it "should show the correct reach for 2013", :vcr do
    CompanyDashboard.reach(2013).should == 303396
  end
  
  it "should show the correct reach for 2014", :vcr do
    CompanyDashboard.reach(2014).should == 775655
  end
  
  it "should show the correct active reach", :vcr do
    CompanyDashboard.reach(2014, "Active").should == 432423
  end
  
  it "should show the correct passive reach", :vcr do
    CompanyDashboard.reach(2014, "Passive").should == 343232
  end

  it "should show the correct bookings value", :vcr do
    CompanyDashboard.bookings(2013).should == 2191064
    CompanyDashboard.bookings(2014).should == 0
    CompanyDashboard.bookings.should == 2191064
  end

  it "should show the correct unlocked value", :vcr do
    CompanyDashboard.value(2013).should == 16924307
    CompanyDashboard.value(2014).should == 775655
    CompanyDashboard.value.should == 16924307
  end

  it "should show the correct kpi percentage", :vcr do
    CompanyDashboard.kpis(2013).should == 100.0
    CompanyDashboard.kpis(2014).should == 1.0
  end

  it "should show the correct network size", :vcr do
    CompanyDashboard.network.should == {
        :total     => 0,
        :breakdown => {
            :members    => 0,
            :nodes      => 0,
            :startups   => 0,
            :affiliates => 0
        }
    }
  end
  
  it "should show total commercial bookings", :vcr do
    CompanyDashboard.bookings_by_type("Commercial", 2014).should == {
      actual: 78.0,
      target: 874.48
    }
  end

  it "should show total non-commercial bookings", :vcr do
    CompanyDashboard.bookings_by_type("Non-commercial", 2014).should == {
      actual: 156.0,
      target: 45.2
    }
  end
  
  it "should show total grant funding", :vcr do
    CompanyDashboard.grant_funding(2014).should == {
      actual: 3040.00,
      target: 3354.6176046176
    }
  end

  it "should show total income", :vcr do
    CompanyDashboard.total_income(2014).should == 666
  end
  
  it "should show income by type", :vcr do
    CompanyDashboard.income_by_type(2014).should == {
      research: 900.00,
      training: 289.00,
      projects: 900.00,
      network: 912.00
    }
  end
  
  it "should show the correct income by sector", :vcr do
    CompanyDashboard.income_by_sector(2014).should == {
      research: {
        commercial: {
          actual: 890.00,
          target: 1500.00
        },
        non_commercial: {
          actual: 423.00,
          target: 750.00
        }
      },
      training: {
        commercial: {
          actual: 87.00,
          target: 128.12
        },
        non_commercial: {
          actual: 121.00,
          target: 180.78
        }
      },
      projects: {
        commercial: {
          actual: 123.00,
          target: 450.00
        },
        non_commercial: {
          actual: 212.00,
          target: 500.00
        }
      },
      network: {
        commercial: {
          actual: 78.00,
          target: 874.48
        },
        non_commercial: {
          actual: 156.00,
          target: 45.2
        }
      }
    }
  end
  
  it "should show headcount", :vcr do
    CompanyDashboard.headcount(2014, 1).should == {
      actual: 22,
      target: 22
    }
  end

  it "should show burn", :vcr do
    CompanyDashboard.burn_rate(2014, 1).should == {
      actual: 320.0,
      target: 314.766666666667
    }
  end
  
#  it "should show grant funding amounts", :vcr do
#    CompanyDashboard.grant_funding(2014).should == 0
#  end

  after :each do
    CompanyDashboard.clear_cache!
  end

end