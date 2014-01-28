require 'spec_helper'

describe QuarterlyProgress do
  it "should show correct progress for each quarter", :vcr do
    progress = QuarterlyProgress.progress(2013)

    progress[:q1].should == 97
    progress[:q2].should == 90.2
    progress[:q3].should == 93.1
    progress[:q4].should == 89.8

    progress = QuarterlyProgress.progress(2014)

    progress[:q1].should == 9.8
    progress[:q2].should == 0
    progress[:q3].should == 0
    progress[:q4].should == 0
  end
end