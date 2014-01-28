require 'spec_helper'

describe CompanyDashboard do

  it "should store right values in metrics API", :vcr do
    Timecop.freeze
    time = DateTime.now
    metrics_api_should_recieve("current-year-reach", time, 0)
    metrics_api_should_recieve("cumulative-reach", time, 303396)
    metrics_api_should_recieve("current-year-bookings", time, 0)
    metrics_api_should_recieve("cumulative-bookings", time, 2191064)
    metrics_api_should_recieve("current-year-value-unlocked", time, 0)
    metrics_api_should_recieve("cumulative-value-unlocked", time, 16924307)
    metrics_api_should_recieve("current-year-kpi-performance", time, 1.0)
    CompanyDashboard.perform
    Timecop.return
  end

  it "should show the correct reach", :vcr do
    CompanyDashboard.reach(2013).should == 303396
    CompanyDashboard.reach(2014).should == 0
    CompanyDashboard.reach.should == 303396
  end

  it "should show the correct bookings value", :vcr do
    CompanyDashboard.bookings(2013).should == 2191064
    CompanyDashboard.bookings(2014).should == 0
    CompanyDashboard.bookings.should == 2191064
  end

  it "should show the correct unlocked value", :vcr do
    CompanyDashboard.value(2013).should == 16924307
    CompanyDashboard.value(2014).should == 0
    CompanyDashboard.value.should == 16924307
  end

  it "should show the correct kpi percentage", :vcr do
    CompanyDashboard.kpis(2013).should == 100.0
    CompanyDashboard.kpis(2014).should == 1.0
  end

  after :each do
    CompanyDashboard.clear_cache!
  end

end