require 'spec_helper'

describe QuarterlyProgress do
  it "should show correct progress for each quarter in 2013", :vcr do
    progress = QuarterlyProgress.progress(2013)
    
    progress[:q1].should == 97
    progress[:q2].should == 90.2
    progress[:q3].should == 93.1
    progress[:q4].should == 90.8
  end
    
  it "should show correct progress for each quarter in 2014", :vcr do
    progress = QuarterlyProgress.progress(2014)

    progress[:q1].should == 91.6
    progress[:q2].should == 87.5
    progress[:q3].should == 63.6
    progress[:q4].should == 10.6
  end

  it "should store right values in metrics API", :vcr do
    Timecop.freeze
    time = DateTime.now
    h    = {
        '2014' => {
            :q1 => 91.6,
            :q2 => 87.5,
            :q3 => 63.6,
            :q4 => 10.6
        },
        '2013' => {
            :q1 => 97.0,
            :q2 => 90.2,
            :q3 => 93.1,
            :q4 => 90.8
        }
    }
    metrics_api_should_receive("quarterly-progress", time, h.to_json)

    QuarterlyProgress.perform
    Timecop.return
  end
end
