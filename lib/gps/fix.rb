# Module representing all data in a GPS fix.
module Gps::Fix

  FIX_ATTRIBUTES = [
    :last_tag,
    :timestamp,
    :timestamp_error_estimate,
    :latitude,
    :longitude,
    :altitude,
    :horizontal_error_estimate,
    :vertical_error_estimate,
    :course,
    :speed,
    :climb,
    :course_error_estimate,
    :speed_error_estimate,
    :climb_error_estimate,
    :satellites
  ]

  FIX_ATTRIBUTES.each { |v| attr_reader v }

  def initialize(*args)
    @altitude = 0
    @latitude = 0
    @longitude = 0
    @speed = 0
    @course = 0
    @satellites = 0
  end

  def to_hash
    h = {}
    FIX_ATTRIBUTES.each { |a| h[a] = send(a) }
    h
  end
end
