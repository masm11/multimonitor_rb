#!/usr/bin/env ruby

require 'gtk3'

require './multimonitor/draw'
require './multimonitor/battery'

# --width 48
# --height 48
# --vertical
# --horizontal
# --font 'sans 8'
# --battery 0
# --battery 1
# --cpufreq 0
# --cpufreq 1
# --cpufreq 2
# --cpufreq 3
# --loadavg 1
# --loadavg 5
# --loadavg 15
# --cpuload 0
# --cpuload 1
# --cpuload 2
# --cpuload 3
# --network eth0
# --network enp0s25
# --network wlp3s0
# --network lo
# --memory
# --swap
# --disk sda
# --temp cpu

####

toplevel = Gtk::Window.new("Multi Monitor")

obj = Battery.new(0)

drawable = Gtk::DrawingArea.new
drawable.set_size_request(48, 48)
toplevel.add(drawable)

obj.read_data

toplevel.show_all

GLib::Timeout.add(1000) do
  obj.read_data
  obj.draw(drawable)
end

Gtk.main
