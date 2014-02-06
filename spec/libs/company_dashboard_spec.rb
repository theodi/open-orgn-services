require 'spec_helper'

describe CompanyDashboard do

  before :each do
    Timecop.freeze(Date.new(2014, 2, 4))
  end

  it "should store right values in metrics API" do
    WebMock.allow_net_connect!
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
      "current-year-kpi-performance"         => 1.0,
      "current-year-grant-funding"           => '{"actual":330000.0,"annual_target":3354617.6046176003,"ytd_target":373917.748917748}',
      "current-year-bookings-by-sector"      => '{"research":{"commercial":{"actual":26000.0,"annual_target":1500000.0,"ytd_target":0.0},"non_commercial":{"actual":77000.0,"annual_target":750000.0,"ytd_target":0.0}},"training":{"commercial":{"actual":75000.0,"annual_target":128120.0,"ytd_target":17360.0},"non_commercial":{"actual":25000.0,"annual_target":180780.0,"ytd_target":14580.0}},"projects":{"commercial":{"actual":1175000.0,"annual_target":450000.0,"ytd_target":0.0},"non_commercial":{"actual":1039000.0,"annual_target":500000.0,"ytd_target":50000.0}},"network":{"commercial":{"actual":245250.0,"annual_target":874480.0,"ytd_target":141440.0},"non_commercial":{"actual":39000.0,"annual_target":45200.0,"ytd_target":25200.0}}}',
      "current-year-headcount"               => '{"actual":22.0,"annual_target":34.0,"ytd_target":26.0}',
      "current-year-burn"                    => 406000.0,
      "current-year-people-trained"          => '{"commercial":{"actual":36,"annual_target":190,"ytd_target":25},"non_commercial":{"actual":55,"annual_target":206,"ytd_target":26}}',
      "current-year-network-size"            => '{"partners":{"actual":3,"annual_target":10,"ytd_target":2},"sponsors":{"actual":1,"annual_target":5,"ytd_target":0},"supporters":{"actual":7,"annual_target":34,"ytd_target":2},"startups":{"actual":7,"annual_target":6,"ytd_target":6},"nodes":{"actual":11,"annual_target":20,"ytd_target":0}}',
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

  it "should show total grant funding", :vcr do
    CompanyDashboard.grant_funding(2014, 2).should == {
      actual:        330000.0,
      annual_target: 3354617.6046176003,
      ytd_target:    373917.748917748,
    }
  end

  it "should show total income", :vcr do
    CompanyDashboard.total_income(2014).should == 6041000.0
  end

  it "should show the correct bookings by sector", :vcr do
    CompanyDashboard.bookings_by_sector(2014, 2).should == {
      research: {
        commercial:     {
          actual:        26000.0,
          annual_target: 1500000.0,
          ytd_target:    0.0,
        },
        non_commercial: {
          actual:        77000.0,
          annual_target: 750000.0,
          ytd_target:    0.0,
        }
      },
      training: {
        commercial:     {
          actual:        75000.0,
          annual_target: 128120.0,
          ytd_target:    17360.0,
        },
        non_commercial: {
          actual:        25000.0,
          annual_target: 180780.0,
          ytd_target:    14580.0,
        }
      },
      projects: {
        commercial:     {
          actual:        1175000.0,
          annual_target: 450000.0,
          ytd_target:    0.0,
        },
        non_commercial: {
          actual:        1039000.0,
          annual_target: 500000.0,
          ytd_target:    50000.0,
        }
      },
      network:  {
        commercial:     {
          actual:        245250.0,
          annual_target: 874480.0,
          ytd_target:    141440.0,
        },
        non_commercial: {
          actual:        39000.0,
          annual_target: 45200.0,
          ytd_target:    25200.0,
        }
      }
    }
  end

  it "should show headcount", :vcr do
    CompanyDashboard.headcount(2014, 2).should == {
        actual:        22.0,
        annual_target: 34.0,
        ytd_target:    26.0,
    }
  end

  it "should show burn", :vcr do
    CompanyDashboard.burn_rate(2014, 2).should == 406000.0
  end

  it "should show number of people trained", :vcr do
    CompanyDashboard.people_trained(2014, 2).should == {
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

  it "should show correct network size", :vcr do
    CompanyDashboard.network_size(2014, 2).should == {
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
    CompanyDashboard.total_costs(2014, 2).should == {
        actual:        762000.0,
        annual_target: 6619594.66666667,
        ytd_target:    1380368.6666666674,
        breakdown: {
            variable: {
                research: {
                    actual: 6000.0,
                    annual_target: 447916.66666666704,
                    ytd_target: 0.0
                },
                training: {
                    actual: 8000.0,
                    annual_target: 123560.0,
                    ytd_target: 12776.0
                },
                projects: {
                    actual: 10000.0,
                    annual_target: 397925.0,
                    ytd_target: 21633.3333333334
                },
                network:  {
                    actual: 12000.0,
                    annual_target: 100695.0,
                    ytd_target: 10187.999999999998
                }
            },
            fixed:    {
                staff:                  {
                    actual: 77000.0,
                    annual_target: 2113000.0,
                    ytd_target: 277000.0
                },
                associates:             {
                    actual: 88000.0,
                    annual_target: 858000.0,
                    ytd_target: 112000.0
                },
                office_and_operational: {
                    actual: 97000.0,
                    annual_target: 494000.0,
                    ytd_target: 82333.3333333334
                },
                delivery:               {
                    actual: 130000.0,
                    annual_target: 778270.0,
                    ytd_target: 81876.6666666666
                },
                communications:         {
                    actual: 154000.0,
                    annual_target: 315000.0,
                    ytd_target: 52500.0
                },
                professional_fees:      {
                    actual: 77000.0,
                    annual_target: 200000.0,
                    ytd_target: 33333.3333333334,
                },
                software:               {
                    actual: 90000.0,
                    annual_target: 110700.0,
                    ytd_target: 16200.0
                }
            }
        }
    }
  end

  after :each do
    Timecop.return
    CompanyDashboard.clear_cache!
  end

end