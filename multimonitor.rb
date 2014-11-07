#!/usr/bin/env ruby
# coding: utf-8

require 'gtk3'

require './multimonitor/draw'
require './multimonitor/battery'
require './multimonitor/cpufreq'

# --vertical
# --horizontal
# --width 48
# --height 48
# --font 'sans 8'
#
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

class Device
  @dev = nil
  def dev=(dev)
    @dev = dev
  end
  def dev
    @dev
  end
  
  @drawable = nil
  def drawable=(drawable)
    @drawable = drawable
  end
  def drawable
    @drawable
  end
  
  @layout = nil
  def layout=(layout)
    @layout = layout
  end
  def layout
    @layout
  end
  
  @pixbuf = nil
  def pixbuf=(pixbuf)
    @pixbuf = pixbuf
  end
  def pixbuf
    @pixbuf
  end
end

width = 48
height = 48
font = 'sans 8'
orientation = :horizontal

toplevel = Gtk::Window.new("Multi Monitor")

devices = []

i = 0
while i < ARGV.length
  case ARGV[i]
  when '--width'
    i += 1
    width = ARGV[i].to_i
    i += 1
    
  when '--height'
    i += 1
    height = ARGV[i].to_i
    i += 1

  when '--font'
    i += 1
    font = ARGV[i]
    i += 1

  when '--vertical'
    i += 1
    orientation = :vertical

  when '--horizontal'
    i += 1
    orientation = :horizontal
    
  when '--battery'
    i += 1
    dev = Device.new
    dev.dev = Battery.new(ARGV[i])
    devices << dev
    i += 1
    
  when '--cpufreq'
    i += 1
    dev = Device.new
    dev.dev = CPUFreq.new(ARGV[i])
    devices << dev
    i += 1
    
  else
    $stderr.puts('unknown args.')
    exit(1)
  end
  
end

box = Gtk::Box.new(orientation, 1)
toplevel.add(box)

fontdesc = Pango::FontDescription.new(font)

for dev in devices
  dev.drawable = Gtk::DrawingArea.new
  dev.drawable.set_size_request(width, height)
  box.add(dev.drawable)
  
  dev.layout = dev.drawable.create_pango_layout
  dev.layout.markup = "<span foreground='white'>" + dev.dev.get_label + "</span>"
  dev.layout.font_description = fontdesc
end

toplevel.show_all

GLib::Timeout.add(1000) do
  i = 0
  while i < devices.length
    dev = devices[i]
    
    pixbuf = Gdk::Pixbuf.new(Gdk::Pixbuf::COLORSPACE_RGB, false, 8, width, height)
    dev.dev.read_data
    dev.dev.draw_all(pixbuf)
    
    ctxt = dev.drawable.window.create_cairo_context
    ctxt.save do
      ctxt.set_source_pixbuf(pixbuf)
      ctxt.paint
    end
    ctxt.show_pango_layout(dev.layout)

    i += 1
  end
  
  true
end

Gtk.main
