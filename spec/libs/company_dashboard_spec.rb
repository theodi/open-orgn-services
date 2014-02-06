require 'spec_helper'

describe CompanyDashboard do

  it "should store right values in metrics API" do
    WebMock.allow_net_connect!
    Timecop.freeze(Date.new(2014, 2, 4))
    time = DateTime.now
    {
      "current-year-reach"                   => 775655,
      "cumulative-reach"                     => 1079051,
      "current-year-active-reach"            => 432423,
      "current-year-passive-reach"           => 343232,
      "current-year-bookings"                => 0,
      "cumulative-bookings"                  => 2191064,
      "current-year-value-unlocked"          => 775655,
      "cumulative-value-unlocked"            => 17699962,
      "current-year-commercial-bookings"     => '{"actual": 78000.0,"target": 874480.0}',
      "current-year-non-commercial-bookings" => '{"actual": 156000.0,"target": 45200.0}',
      "current-year-kpi-performance"         => 1.0,
      "current-year-grant-funding"           => '{"actual": 3040000.0,"target": 3354617.6046176003}',
      "current-year-income-by-type"          => '{"research": 900000.0,"training": 289000.0,"projects": 900000.0,"network": 912000.0}',
      "current-year-income-by-sector"        => '{"research":{"commercial":{"actual":890000.0,"target":1500000.0},"non_commercial":{"actual":423000.0,"target":750000.0}},"training":{"commercial":{"actual":87000.0,"target":128120.0},"non_commercial":{"actual":121000.0,"target":180780.0}},"projects":{"commercial":{"actual":123000.0,"target":450000.0},"non_commercial":{"actual":212000.0,"target":500000.0}},"network":{"commercial":{"actual":78000.0,"target":874480.0},"non_commercial":{"actual":156000.0,"target":45200.0}}}',
      "current-year-headcount"               => '{"actual": 22.0,"target": 26.0}',
      "current-year-burn"                    => '{"actual": 0.0,"target": 340476.666666667}',
      "current-year-people-trained"          => '{"commercial": {"actual": 0,"target": 190}, "non_commercial": {"actual": 0,"target": 206}}',
      "current-year-network-size"            => '{"partners":{"actual":0,"target":10},"sponsors":{"actual":0,"target":5},"supporters":{"actual":0,"target":34},"startups":{"actual":0,"target":6},"nodes":{"actual":0,"target":20}}',
      "current-year-ebitda"                  => '{"actual":275500.0, "target":-82789.7922077922}',
      "current-year-total-costs"             => '{"actual":0.0,"target":365602.0000000003,"breakdown":{"variable":{"research":{"actual":0.0,"target":0.0},"training":{"actual":0.0,"target":8920.0},"projects":{"actual":0.0,"target":10816.6666666667},"network":{"actual":0.0,"target":5388.66666666667}},"fixed":{"staff":{"actual":0.0,"target":147000.0},"associates":{"actual":0.0,"target":57000.0},"office_and_operational":{"actual":0.0,"target":41166.6666666667},"delivery":{"actual":0.0,"target":43993.3333333333},"communications":{"actual":0.0,"target":26250.0},"professional_fees":{"actual":0.0,"target":16666.6666666667},"software":{"actual":0.0,"target":8400.0}}}}',
    }.each_pair do |metric, value|
      metrics_api_should_receive metric, time, value
    end

    CompanyDashboard.perform
    Timecop.return
    WebMock.disable_net_connect!
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
    CompanyDashboard.value.should == 17699962
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
        actual: 78000.0,
        target: 874480.0
    }
  end

  it "should show total non-commercial bookings", :vcr do
    CompanyDashboard.bookings_by_type("Non-commercial", 2014).should == {
        actual: 156000.0,
        target: 45200.0
    }
  end

  it "should show total grant funding", :vcr do
    CompanyDashboard.grant_funding(2014).should == {
        actual: 3040000.0,
        target: 3354617.6046176003
    }
  end

  it "should show total income", :vcr do
    CompanyDashboard.total_income(2014).should == 6041000.0
  end

  it "should show income by type", :vcr do
    CompanyDashboard.income_by_type(2014).should == {
        research: 900000.0,
        training: 289000.0,
        projects: 900000.0,
        network:  912000.0
    }
  end

  it "should show the correct income by sector", :vcr do
    CompanyDashboard.income_by_sector(2014).should == {
        research: {
            commercial:     {
                actual: 890000.0,
                target: 1500000.0
            },
            non_commercial: {
                actual: 423000.0,
                target: 750000.0
            }
        },
        training: {
            commercial:     {
                actual: 87000.0,
                target: 128120.0
            },
            non_commercial: {
                actual: 121000.0,
                target: 180780.0
            }
        },
        projects: {
            commercial:     {
                actual: 123000.0,
                target: 450000.0
            },
            non_commercial: {
                actual: 212000.0,
                target: 500000.0
            }
        },
        network:  {
            commercial:     {
                actual: 78000.0,
                target: 874480.0
            },
            non_commercial: {
                actual: 156000.0,
                target: 45200.0
            }
        }
    }
  end

  it "should show headcount", :vcr do
    Timecop.freeze(Date.new(2014, 2, 4))
    CompanyDashboard.headcount(2014, 2).should == {
        actual: 22.0,
        target: 26.0
    }
    Timecop.return
  end

  it "should show burn", :vcr do
    Timecop.freeze(Date.new(2014, 1, 4))
    CompanyDashboard.burn_rate(2014, 1).should == {
        actual: 320000.0,
        target: 314766.666666667
    }
    Timecop.return
  end

  it "should show number of people trained", :vcr do
    CompanyDashboard.people_trained(2014).should == {
        commercial:     {
            actual: 0,
            target: 190
        },
        non_commercial: {
            actual: 0,
            target: 206
        }
    }
  end

  it "should show correct network size", :vcr do
    CompanyDashboard.network_size(2014).should == {
        partners:   {
            actual: 0,
            target: 10
        },
        sponsors:   {
            actual: 0,
            target: 5
        },
        supporters: {
            actual: 0,
            target: 34
        },
        startups:   {
            actual: 0,
            target: 6
        },
        nodes:      {
            actual: 0,
            target: 20
        }
    }
  end

  it "should load EBITDA information", :vcr do
    Timecop.freeze(Date.new(2014, 1, 4))
    CompanyDashboard.ebitda(2014, 1).should == {
        actual: -44500.0,
        target: -69979.7922077923
    }
    Timecop.return
  end

  it "should load total cost information", :vcr do
    Timecop.freeze(Date.new(2014, 1, 4))
    CompanyDashboard.total_costs(2014, 1).should == {
        actual:    320000.0,
        target:    334238.666666667,
        breakdown: {
            variable: {
                research: {
                    actual: 0.0,
                    target: 0.0
                },
                training: {
                    actual: 0.0,
                    target: 3856.0
                },
                projects: {
                    actual: 0.0,
                    target: 10816.6666666667
                },
                network:  {
                    actual: 0.0,
                    target: 4799.333333333329
                }
            },
            fixed:    {
                staff:                  {
                    actual: 5432000.0,
                    target: 130000.0
                },
                associates:             {
                    actual: 54000.0,
                    target: 55000.0
                },
                office_and_operational: {
                    actual: 4321000.0,
                    target: 41166.6666666667
                },
                delivery:               {
                    actual: 54000.0,
                    target: 37883.3333333333
                },
                communications:         {
                    actual: 6543000.0,
                    target: 26250.0
                },
                professional_fees:      {
                    actual: 765000.0,
                    target: 16666.6666666667
                },
                software:               {
                    actual: 4324000.0,
                    target: 7800.0
                }
            }
        }
    }
    Timecop.return
  end

  after :each do
    CompanyDashboard.clear_cache!
  end

end