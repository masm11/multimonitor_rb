#!/usr/bin/env ruby

require './multimonitor/draw'

class Battery
  def initialize(dev)
    @data = []
    @dev = dev
    @pixbuf = Gdk::Pixbuf.new(Gdk::Pixbuf::COLORSPACE_RGB, false, 8, 48, 48)
  end
  
  def read_data
    h = nil
    
    begin
      cap = -1
      charging = false
      
      File::open("/sys/class/power_supply/BAT#{@dev}/capacity") do |f|
        f.each_line do |line|
          cap = line.to_i
        end
      end
      
      File::open("/sys/class/power_supply/BAT#{@dev}/status") do |f|
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

  def draw(w)
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
end

