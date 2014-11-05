#!/usr/bin/env ruby

require 'gtk3'

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

def battery_init(dev)
  @data = []
  # colorspace, has_alpha, bits_per_sample, width, height
  @pixbuf = Gdk::Pixbuf.new(Gdk::Pixbuf::COLORSPACE_RGB, false, 8, 48, 48)
end

def battery_read_data(dev)
  h = nil
  
  begin
    cap = -1
    charging = false
    
    File::open("/sys/class/power_supply/BAT#{dev}/capacity") do |f|
      f.each_line do |line|
        cap = line.to_i
      end
    end
    
    File::open("/sys/class/power_supply/BAT#{dev}/status") do |f|
      f.each_line do |line|
        if /^Charging/ =~ line
          charging = true
        end
      end
    end
    
#    p cap
#    p charging
    h = {
      'capacity' => cap,
      'charging' => charging,
    }
  rescue => e
#    p e
  end
  
  @data << h
end

def battery_draw(dev, w)
  i = @data.length - 1
  x = 47
  while x >= 0
    if i >= 0
      h = @data[i]
      p h['capacity']
      
      height = h['capacity'] * 48 / 100
      
      if h['charging']
        draw_line(@pixbuf, x, 0, 47, 0, 0x80, 0)
        draw_line(@pixbuf, x, 47 - height + 1, 47, 0xff, 0x80, 0x80)
      else
        draw_line(@pixbuf, x, 0, 47, 0, 0, 0)
        draw_line(@pixbuf, x, 47 - height + 1, 47, 0xff, 0, 0)
      end
    else
      p 'no data.'
      draw_line(@pixbuf, x, 0, 47, 0x80, 0x80, 0x80)
    end

    x -= 1
    i -= 1
  end
  
  ctxt = w.window.create_cairo_context
  ctxt.save do
    ctxt.set_source_pixbuf(@pixbuf)
    ctxt.paint
  end
end

####

def draw_line(pixbuf, x, y1, y2, r, g, b)
  p 'draw_line'
  rowstride = pixbuf.rowstride
  pixels = pixbuf.pixels;
  
  for y in y1..y2
    p = y * rowstride + x * 3
    pixels[p..p+2] = [ r, g, b ].pack('C3')
  end
  
#  pixels[0] = "\x00"
#  pixels[1] = "\x00"
#  pixels[2] = "\x00"
  pixbuf.pixels = pixels
#  p pixbuf.pixels
end

####

toplevel = Gtk::Window.new("Multi Monitor")

drawable = Gtk::DrawingArea.new
drawable.set_size_request(48, 48)
toplevel.add(drawable)

battery_init(0)
battery_read_data(0)

toplevel.show_all

GLib::Timeout.add(1000) do
  battery_read_data(0)
  battery_draw(0, drawable)
end

Gtk.main
