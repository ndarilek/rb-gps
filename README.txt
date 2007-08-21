= GPS Library for Ruby

This library provides a Ruby interface to GPS receivers. Features include:
* Support for multiple receivers. +Receiver+ connects to a GPS and obtains all data in a +Fix+.
* GPSD +Receiver+ for obtaining data from units supported by GPSD.
* Event callbacks for position, speed and course change.
* Plugin architecture. Distribute new +Receiver+ implementations as gems.

== Installation

Simply install via gems with the command:

gem install gps

Or run the included setup.rb like so:

ruby setup.rb config
ruby setup.rb install

== Example usage

There are a few simple steps to using this library, but before doing any of them you must first:

require "gps"

=== Create the +Receiver+

A +Receiver+ is created by calling +Gps::Receiver.create+ with an implementation and hash of options. If no implementation is given, the first found implementation is used. In a stock installation without any additional plugins, the following calls are equivalent:

gps = Gps::Receiver.create
gps = Gps::Receiver.create("gpsd")
gps = Gps::Receiver.create(:host => "localhost", :port => 2947)
gps = Gps::Receiver.create("gpsd", :host => "localhost")

The GPSD +Receiver+ supports both _:host_ and _:port_ options which point to a host on which a GPSD instance is running. +Receiver+ options are not standard.

=== Start the +Receiver+

The +Receiver+ is now created, but is not yet polling the hardware. To start this process, run:

gps.start

Verify that this has succeeded by running:

gps.started?

Assuming this succeeded, you can now access _gps.latitude_, _gps.longitude_, _gps.altitude, _gps.course_, _gps.speed_ and other variables exposed via +Fix+.

=== Callbacks

You can also register callbacks which are triggered on various GPS events like so:

gps.on_position_change { puts "Latitude = #{gps.latitude}, longitude = #{gps.longitude}" }
gps.on_course_change { puts "Course = #{gps.course}" }
gps.on_speed_change { puts "Speed = #{gps.speed}" }

+Receiver#on_position_change+ supports an additional _threshold_. Because of GPS drift, positions change often. As such, it is possible to specify a threshold like so:

gps.on_position_change(0.0002) { puts "Latitude = #{gps.latitude}, longitude = #{gps.longitude}" }

The callback will not trigger on position changes of less than 0.0002 degrees since it was last called.

=== Cleaning up

To close devices or connections and no longer receive GPS updates, call the following method:

gps.stop

== Hacking

The GPSD +Receiver+ should be sufficient for most needs. If, however, you wish to parse NMEA data directly, interface with raw serial ports or interact with your GPS hardware on a lower level, a new +Receiver+ implementation is necessary. This section is a quick overview to writing +Receiver+ implementations.

When overriding the below methods, +super+ should be the last method called. Also, as polling happens in a separate thread, +Receiver+ code should be thread-safe.

=== Use +Gps::Receivers+

The library looks up +Receiver+ implementations in the +Gps::Receivers+ module. Therefore, all implementations must be defined there.

=== Override +Receiver#start+

This method should open the device, initiate a connection, etc.

=== Override +Receiver#stop+, if Necessary

The default +stop+ method simply kills the thread and sets it to _nil_. If this is sufficient, overriding is unnecessary.

=== Override +Receiver#update+

This method should read an update from the device, setting the variables exposed by +Fix+.

=== Make it a Plugin

If the gem_plugin library is installed, new +Receivers+ distributed as gems can be integrated automatically with a few simple steps.
1. Distribute your +Receiver+ as a gem that depends on both the gps and gem_plugin gems.
2. Add the following code to your plugin:

GemPlugin::Manager.instance.create("/receivers/your_receiver_name", :optional_option => :value)