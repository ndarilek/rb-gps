require File.dirname(__FILE__) + '/spec_helper.rb'

describe Gps::Receivers::Gpsd do

	it "initializes itself with a host of localhost and port 2947 by default" do
		gps = Gps::Receiver.create("gpsd")
		gps.host.should == "localhost"
		gps.port.should == 2947
	end

	it "initializes itself with the specified host and port" do
		gps = Gps::Receiver.create("gpsd", :host => "foo.com", :port => 123)
		gps.host.should == "foo.com"
		gps.port.should == 123
	end

	it "opens a socket to its host and port and activates watcher mode when started" do
		gps = Gps::Receiver.create
		socket = mock("socket")
		TCPSocket.should_receive(:new).with(gps.host, gps.port).and_return(socket)
		socket.should_receive(:puts).with("w+")
		gps.start
	end

	it "correctly parses O sentences on update" do
		line = "GPSD,O=MID2 1187698425.040 0.005 53.527158 -113.530148 704.05 2.00 1.73 0.0000 0.074 0.101 ? ? ? 3\r\n"
		gps = Gps::Receiver.create
		socket = mock("socket")
		TCPSocket.should_receive(:new).with(gps.host, gps.port).and_return(socket)
		socket.should_receive(:puts).with("w+")
		socket.should_receive(:gets).any_number_of_times.and_return(line)
		gps.start
		params = line.chomp.split("=")[1].split
		gps.last_tag.should == params[0]
		gps.timestamp.should == params[1].to_f
		gps.timestamp_error_estimate.should == params[2].to_f
		gps.latitude.should == params[3].to_f
		gps.longitude.should == params[4].to_f
		gps.altitude.should == params[5].to_f
		gps.horizontal_error_estimate.should == params[6].to_f
		gps.vertical_error_estimate.should == params[7].to_f
		gps.course.should == params[8].to_f
		gps.speed.should == params[9].to_f
		gps.climb.should == params[10].to_f
		gps.course_error_estimate.should == params[11].to_f
		gps.speed_error_estimate.should == params[12].to_f
		gps.climb_error_estimate.should == params[13].to_f
		end
end