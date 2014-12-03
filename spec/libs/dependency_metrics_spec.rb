require 'spec_helper'

describe DependencyMetrics, :vcr do

  before :each do
    Timecop.freeze
    @time = Time.now
  end

  it "should store right values in metrics API" do
    expected = {
      current: 470,
      warning: 704,
      danger: 16,
      alerts: 99,
    }
    # Which methods are called?
    DependencyMetrics.should_receive(:dependencies).once.and_call_original
    # How many metrics are stored?
    metrics_api_should_receive("gemnasium-dependencies", @time, expected.to_json)
    # Do it
    DependencyMetrics.perform
  end
    
  it "should get correct value for up-to-date dependencies" do
    DependencyMetrics.dependencies[:current].should eq 470
  end

  it "should get correct value for out-of-date dependencies" do
    DependencyMetrics.dependencies[:warning].should eq 704
  end

  it "should get correct value for dangerously out-of-date dependencies" do
    DependencyMetrics.dependencies[:danger].should eq 16
  end

  it "should get correct value for open alerts" do
    DependencyMetrics.dependencies[:alerts].should eq 99
  end
  
  after :each do
    Timecop.return
  end

end
