require "socket"
require 'time' # without this require we get: undefined method `parse' for Time:Class Error
require 'json'

# Represents a +Receiver+ that obtains information from GPSD.
module Gps::Receivers
  class Gpsd < Gps::Receiver
    attr_reader :host, :port

    # Accepts an options +Hash+ consisting of the following:
    # * _:host_: The host to which to connect
    # * _:port_: The port to which to connect
    def initialize(options = {})
      super
      @host ||= options[:host] ||= "localhost"
      @port = options[:port] ||= 2947
    end

    def start
      return if started?
      @socket = TCPSocket.new(@host, @port)
      @socket.puts('?WATCH={"enable":true,"json":true}')
      super
    end
    
    def stop
      @socket.puts('?WATCH={"enable":false}')
      super
    end

    def update
      line = @socket.gets
      return unless line
      gps_info = JSON.parse line
      
      # {"class"=>"TPV", "tag"=>"GLL", "device"=>"/dev/ttyAMA0", "mode"=>3, "time"=>"2013-10-27T07:16:30.000Z", 
      # "ept"=>0.005, 
      # "lat"=>48.1635725, "lon"=>17.129116333, "alt"=>45.9, "epx"=>21.061, 
      # "epy"=>5.952, "epv"=>5.75, "track"=>0.0, "speed"=>2.009, "climb"=>0.0}
      if gps_info['class'] == 'TPV'
        @last_tag = gps_info['tag']
        @timestamp = Time.parse(gps_info['time']).to_f   # "2013-10-27T07:16:30.000Z"
        @timestamp_error_estimate = gps_info['ept'].to_f
        @latitude = gps_info['lat'].to_f
        @longitude = gps_info['lon'].to_f
        @altitude = gps_info['alt'].to_f
        @horizontal_error_estimate = nil # TODO: not sure which ep? maps to which attribute
        @vertical_error_estimate = nil
        @course = gps_info['track'].to_f
        @speed = gps_info['speed'].to_f
        @climb = gps_info['climb'].to_f
        @course_error_estimate = nil
        @speed_error_estimate = nil
        @climb_error_estimate = nil 
        
        # {"class"=>"SKY", "tag"=>"GSV", "device"=>"/dev/ttyAMA0", "xdop"=>0.62, "ydop"=>0.57, "vdop"=>1.09, "tdop"=>0.65, "hdop"=>0.84, "gdop"=>1.53, "pdop"=>1.38, "satellites"=>[{"PRN"=>1, "el"=>52, "az"=>297, "ss"=>0, "used"=>false}, {"PRN"=>3, "el"=>22, "az"=>177, "ss"=>31, "used"=>true}, {"PRN"=>6, "el"=>9, "az"=>164, "ss"=>34, "used"=>true}, {"PRN"=>11, "el"=>75, "az"=>277, "ss"=>16, "used"=>true}, {"PRN"=>14, "el"=>46, "az"=>78, "ss"=>15, "used"=>true}, {"PRN"=>17, "el"=>0, "az"=>325, "ss"=>0, "used"=>false}, {"PRN"=>19, "el"=>50, "az"=>183, "ss"=>40, "used"=>true}, {"PRN"=>20, "el"=>20, "az"=>245, "ss"=>37, "used"=>true}, {"PRN"=>22, "el"=>23, "az"=>63, "ss"=>0, "used"=>false}, {"PRN"=>24, "el"=>2, "az"=>16, "ss"=>0, "used"=>false}, {"PRN"=>27, "el"=>18, "az"=>166, "ss"=>43, "used"=>true}, {"PRN"=>28, "el"=>18, "az"=>298, "ss"=>20, "used"=>true}, {"PRN"=>32, "el"=>55, "az"=>236, "ss"=>43, "used"=>true}, {"PRN"=>33, "el"=>26, "az"=>220, "ss"=>0, "used"=>false}, {"PRN"=>37, "el"=>35, "az"=>174, "ss"=>38, "used"=>false}, {"PRN"=>39, "el"=>34, "az"=>169, "ss"=>40, "used"=>false}]}
      elsif gps_info['class'] == 'SKY'
        @satellites = gps_info['satellites'].size
        
        # there is also following info provided by gpsd, but we ignore it for now:
        # {"class"=>"VERSION", "release"=>"3.6", "rev"=>"3.6", "proto_major"=>3, "proto_minor"=>7}
        # {"class"=>"DEVICES", "devices"=>[{"class"=>"DEVICE", "path"=>"/dev/ttyAMA0", "activated"=>"2013-10-27T14:20:45.696Z", "native"=>0, "bps"=>9600, "parity"=>"N", "stopbits"=>1, "cycle"=>1.0}]}
      end
      
      super
    end
  end
end
