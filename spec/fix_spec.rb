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
	end
end