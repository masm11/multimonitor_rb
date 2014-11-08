#!/usr/bin/env ruby

require_relative 'draw'

class Battery
  def initialize(dev)
    @data = []
    @dev = dev
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
  
  def draw_1(pixbuf)
    width = pixbuf.width
    height = pixbuf.height
    
    draw_shift(pixbuf)
    
    i = @data.length - 1
    x = width - 1
    
    if i >= 0 && @data[i]
      h = @data[i]
      
      len = h['capacity'] * height / 100
      
      if h['charging']
        draw_line(pixbuf, x, 0, height - 1, 0, 0x80, 0)
        draw_line(pixbuf, x, height - len, height - 1, 0xff, 0x80, 0x80)
      else
        draw_line(pixbuf, x, 0, height - 1, 0, 0, 0)
        draw_line(pixbuf, x, height - len, height - 1, 0xff, 0, 0)
      end
    else
      draw_line(pixbuf, x, 0, height - 1, 0x80, 0x80, 0x80)
    end
  end
  
  def draw_all(pixbuf)
    width = pixbuf.width
    height = pixbuf.height
    
    i = @data.length - 1
    x = width - 1
    while x >= 0
      if i >= 0 && @data[i]
        h = @data[i]
#        p h['capacity']
        
        len = h['capacity'] * height / 100
        
        if h['charging']
          draw_line(pixbuf, x, 0, height - 1, 0, 0x80, 0)
          draw_line(pixbuf, x, height - len, height - 1, 0xff, 0x80, 0x80)
        else
          draw_line(pixbuf, x, 0, height - 1, 0, 0, 0)
          draw_line(pixbuf, x, height - len, height - 1, 0xff, 0, 0)
        end
      else
#        p 'no data.'
        draw_line(pixbuf, x, 0, height - 1, 0x80, 0x80, 0x80)
      end
      
      x -= 1
      i -= 1
    end
  end
  
  def get_label
    "Battery\nBAT #{@dev}"
  end
  
  def get_tick_per_draw
    16
  end
  
  def discard_data(maxlen)
    if @data.length > maxlen
      @data.slice!(0, @data.length - maxlen)
    end
  end
  
  def get_tooltip_text
    h = @data[@data.length - 1]
    return nil unless h
    sprintf("%d%%\n%scharging",
            h['capacity'],
            h['charging'] ? '' : 'dis')
  end
end

