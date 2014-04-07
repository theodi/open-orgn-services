require 'spec_helper'

describe QuarterlyProgress do
  it "should show correct progress for each quarter", :vcr do
    progress = QuarterlyProgress.progress(2013)

    progress[:q1].should == 97
    progress[:q2].should == 90.2
    progress[:q3].should == 93.1
    progress[:q4].should == 89.8

    progress = QuarterlyProgress.progress(2014)

    progress[:q1].should == 67.5
    progress[:q2].should == 7.9
    progress[:q3].should == 0
    progress[:q4].should == 0
  end

  it "should store right values in metrics API", :vcr do
    Timecop.freeze
    time = DateTime.now
    h    = {
        '2014' => {
            :q1 => 67.5,
            :q2 => 7.9,
            :q3 => 0,
            :q4 => 0
        },
        '2013' => {
            :q1 => 97.0,
            :q2 => 90.2,
            :q3 => 93.1,
            :q4 => 89.8
        }
    }
    metrics_api_should_receive("quarterly-progress", time, h.to_json)

    QuarterlyProgress.perform
    Timecop.return
  end
end
