#!/usr/bin/env ruby

require "rubygems"
require "ruby-debug"
$: << File.dirname(__FILE__)+"/../lib"
require "gps"
begin
  require "json"
rescue
end
require "sinatra"
begin
  require "yaml"
rescue
end

configure do
  host = ARGV.shift
  host ||= "localhost"
  port = ARGV.shift.to_i
  port = 2947 if port == 0
  puts "Accessing GPS at #{host}:#{port}"
  $gps = Gps::Receiver.create(:host => host, :port => port)
  $gps.start
  unless $gps.started?
    puts "Error starting GPS."
    exit(1)
  end
end

get "/fix.*" do
  $gps.to_hash.send("to_#{params['splat'][0]}")
end
