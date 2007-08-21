$:.unshift File.dirname(__FILE__)

module Gps
end

Dir["#{File.dirname(__FILE__)}/gps/**/*.rb"].each { |f| require f }