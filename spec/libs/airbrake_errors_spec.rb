require 'spec_helper'

describe ApplicationErrors, :vcr do

  before :each do
    Timecop.freeze
    @time = Time.now
  end

  it "should get correct value for application error count" do
    ApplicationErrors.unresolved_errors.should eq 322
  end
  
  it "should store right values in metrics API" do
    # Which methods are called?
    ApplicationErrors.should_receive(:unresolved_errors).once.and_call_original
    # How many metrics are stored?
    metrics_api_should_receive("application-errors", @time, 322)
    # Do it
    ApplicationErrors.perform
  end
    
  after :each do
    Timecop.return
  end

end
