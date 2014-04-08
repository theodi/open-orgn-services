require 'spec_helper'

describe FinancialMetrics do

  before :each do
    Timecop.freeze(Date.new(2014, 2, 4))
  end

  it "should store right values in metrics API" do
    # Which methods are called?
    FinancialMetrics.should_receive(:cash_reserves).with(2014).once
    FinancialMetrics.should_receive(:value).with(2014).once
    FinancialMetrics.should_receive(:value).with(nil).once
    FinancialMetrics.should_receive(:income).with(2014, 2).once
    FinancialMetrics.should_receive(:income).with(nil, nil).once
    FinancialMetrics.should_receive(:bookings).with(nil).once
    FinancialMetrics.should_receive(:kpis).with(2014).once
    FinancialMetrics.should_receive(:grant_funding).with(2014, 2).once
    FinancialMetrics.should_receive(:bookings_by_sector).with(2014, 2).once
    FinancialMetrics.should_receive(:headcount).with(2014, 2).once
    FinancialMetrics.should_receive(:burn_rate).with(2014, 2).once
    FinancialMetrics.should_receive(:ebitda).with(2014, 2).once
    FinancialMetrics.should_receive(:total_costs).with(2014, 2).once
    # How many metrics are stored?
    FinancialMetrics.should_receive(:store_metric).exactly(13).times
    # Do it
    FinancialMetrics.perform
  end

  it "should show the correct unlocked value", :vcr do
    FinancialMetrics.value(2013).should == 15210243
    FinancialMetrics.value(2014).should == 544441
    FinancialMetrics.value.should == 15754684
  end

  it "should show the correct kpi percentage", :vcr do
    FinancialMetrics.kpis(2013).should == 100.0
    FinancialMetrics.kpis(2014).should == 38.0
  end

  it "should show total grant funding", :vcr do
    FinancialMetrics.grant_funding(2014, 2).should == {
      actual:        330000.0,
      annual_target: 3354617.6046176003,
      ytd_target:    373917.748917748,
    }
  end

  it "should show income", :vcr do
    FinancialMetrics.income(2014, 2).should == {
      actual:        255270.833333333,
      annual_target: 2935183.33333333,
      ytd_target:    173153.3333333333,
    }
  end

  it "should show cumulative income", :vcr do
    FinancialMetrics.income(nil, nil).should == 3123 + 255000
  end

  it "should show cash reserves", :vcr do
    FinancialMetrics.cash_reserves(2014).should == 1015006.28
  end

  it "should show correct cumulative bookings", :vcr do
    FinancialMetrics.bookings(nil).should == 686000
  end

  it "should show the correct bookings by sector", :vcr do
    FinancialMetrics.bookings_by_sector(2014, 2).should == {
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
    FinancialMetrics.headcount(2014, 2).should == {
        actual:        22.0,
        annual_target: 34.0,
        ytd_target:    26.0,
    }
  end

  it "should show burn", :vcr do
    FinancialMetrics.burn_rate(2014, 2).should == 363000.0
    FinancialMetrics.burn_rate(2014, 4).should == 375333.3333333333
    FinancialMetrics.burn_rate(2014, 5).should == 375333.3333333333
  end

  it "should load EBITDA information", :vcr do
    FinancialMetrics.ebitda(2014, 2).should == {
      actual:        -506729.166666667,
      latest:        -369000.0,
      annual_target: -3684411.3333333298,
      ytd_target:    -1207215.333333334,
    }
  end

  it "should load total cost information", :vcr do
    FinancialMetrics.total_costs(2014, 2).should == {
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
    FinancialMetrics.clear_cache!
  end

end
