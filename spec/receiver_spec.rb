require File.dirname(__FILE__) + '/spec_helper.rb'

describe Gps::Receiver do

	it "supports setting latitude and longitude via the position attribute" do
		gps = Gps::Receiver.new
		gps.position = [20, 30]
		gps.latitude.should == 20
		gps.longitude.should == 30
	end

	it "should call the on_position_change callback on position changes" do
		gps = Gps::Receiver.new
		called = false
		gps.on_position_change { called = true }
		gps.position = [20, 30]
		called.should == true
	end

	it "should not call the on_position_change callback if the position change is below the specified threshold" do
		gps = Gps::Receiver.new
		called = false
		gps.on_position_change(5) { called = true }
		gps.position = [0, 1]
		called.should == false
	end

	it "should call the on_position_change callback if the position change is above the specified threshold" do
		gps = Gps::Receiver.new
		called = false
		gps.on_position_change(5) { called = true }
		gps.position = [0, 6]
		called.should == true
	end

	it "should cope with intermediate position changes, not calling on_position_change until the threshold is exceeded" do
		gps = Gps::Receiver.new
		called = false
		gps.on_position_change(5) { called = true }
		gps.position = [0, 4]
		called.should == false
		gps.position = [0, 6]
		called.should == true
	end

	it "should call position, speed and course change callbacks when updated, if necessary" do
		gps = Gps::Receiver.new
		course_changed = speed_changed = position_changed = nil
		gps.on_position_change { position_changed = true }
		gps.on_speed_change { speed_changed = true }
		gps.on_course_change { course_changed = true }
		gps.instance_eval("@latitude = 5")
		gps.instance_eval("@speed = 10")
		gps.instance_eval("@course = 1")
		gps.update
		course_changed.should == true
		position_changed.should == true
		speed_changed.should == true
	end

	it "should spawn a new, updating thread when started" do
		gps = Gps::Receiver.new
		gps.should_receive(:update).any_number_of_times
		gps.start
	end

	it "should report that it is started" do
		gps = Gps::Receiver.new
		gps.start
		gps.started?.should == true
	end

	it "should report that it is not started before start has been called" do
		gps = Gps::Receiver.new
		gps.started?.should == false
	end

	it "should kill its update thread when stopped" do
		gps = Gps::Receiver.new
		gps.start
		gps.started?.should == true
		gps.stop
		gps.started?.should == false
	end
end