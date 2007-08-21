$:.unshift File.dirname(__FILE__)

module Gps
end

begin
	require "rubygems"
rescue LoadError
end

if Object.const_defined?("Gem")
	begin
		require "gem_plugin"
	rescue LoadError
	end
end

Dir["#{File.dirname(__FILE__)}/gps/**/*.rb"].each { |f| require f }

GemPlugin::Manager.instance.load "gps" => GemPlugin::INCLUDE if Object.const_defined?("GemPlugin")