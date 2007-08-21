require "socket"

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
			@socket = TCPSocket.new(@host, @port)
			@socket.puts("w+")
			super
		end

		def update
			line = @socket.gets.chomp.split(",")[1]
			return if !line
			types = []
			data = []
			line.split(",").each do |sentence|
				sentence.split("=").each_with_index  do |d, i|
					if i%2 == 0
						types << d
					else
						data << d
					end
				end
			end
			types.each_with_index do |type, i|
				begin
					send("parse_#{type.downcase}", data[i])
				rescue NoMethodError
				end
			end
			super
		end

		private
		def parse_o(data)
			params = data.split
			@last_tag = params[0]
			@timestamp = params[1].to_f
			@timestamp_error_estimate = params[2].to_f
			@latitude = params[3].to_f
			@longitude = params[4].to_f
			@altitude = params[5].to_f
			@horizontal_error_estimate = params[6].to_f
			@vertical_error_estimate = params[7].to_f
			@course = params[8].to_f
			@speed = params[9].to_f
			@climb = params[10].to_f
			@course_error_estimate = params[11].to_f
			@speed_error_estimate = params[12].to_f
			@climb_error_estimate = params[13].to_f
		end

		def parse_y(data)
			@satellites = data.split(":")[0].split[-1].to_i
		end
	end
end