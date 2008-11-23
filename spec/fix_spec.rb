require File.dirname(__FILE__) + '/spec_helper.rb'

describe Gps::Fix do

  class Fix
    include Gps::Fix
  end

  it "initializes GPS fix values to nil or 0" do
    fix = Fix.new
    fix.last_tag.should == nil
    fix.timestamp.should == nil
    fix.timestamp_error_estimate.should == nil
    fix.latitude.should == 0
    fix.longitude.should == 0
    fix.altitude.should == 0
    fix.horizontal_error_estimate.should == nil
    fix.vertical_error_estimate.should == nil
    fix.course.should == 0
    fix.speed.should == 0
    fix.climb.should == nil
    fix.course_error_estimate.should == nil
    fix.speed_error_estimate.should == nil
    fix.climb_error_estimate.should == nil
    fix.satellites.should == 0
  end

  it "returns a hash of its values" do
    fix = Fix.new
    h = fix.to_hash
    h[:last_tag].should == nil
    h[:timestamp].should == nil
    h[:timestamp_error_estimate].should == nil
    h[:latitude].should == 0
    h[:longitude].should == 0
    h[:altitude].should == 0
    h[:horizontal_error_estimate].should == nil
    h[:vertical_error_estimate].should == nil
    h[:course].should == 0
    h[:speed].should == 0
    h[:climb].should == nil
    h[:course_error_estimate].should == nil
    h[:speed_error_estimate].should == nil
    h[:climb_error_estimate].should == nil
    h[:satellites].should == 0
  end

end
