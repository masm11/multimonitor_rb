#!/usr/bin/env ruby

require './multimonitor/draw'

class Temp
  def initialize(dev)
    @data = []
    @max = nil
    
    begin
      File::open("/sys/devices/platform/coretemp.0/hwmon/hwmon1/temp1_max") do |f|
        f.each_line do |line|
          @max = line.to_i / 1000.0
        end
      end
    rescue => e
      p e
    end
  end
  
  def read_data
    temp = nil
    
    begin
      File::open("/sys/devices/platform/coretemp.0/hwmon/hwmon1/temp1_input") do |f|
        f.each_line do |line|
          temp = line.to_i / 1000.0
        end
      end
    rescue => e
      p e
    end
    
    @data << temp
  end
  
  def draw_1(pixbuf)
    width = pixbuf.width
    height = pixbuf.height
    
    draw_shift(pixbuf)
    
    i = @data.length - 1
    x = width - 1
    
    if @max && i >= 0 && @data[i]
      temp = @data[i]
      
      len = height * temp / @max
      
      draw_line(pixbuf, x, 0, height - 1, 0, 0, 0)
      draw_line(pixbuf, x, height - len, height - 1, 0xff, 0x00, 0x00)
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
      if @max && i >= 0 && @data[i]
        temp = @data[i]
        
        len = height * temp / total
        
        draw_line(pixbuf, x, 0, height - 1, 0, 0, 0)
        draw_line(pixbuf, x, height - len, height - 1, 0xff, 0x00, 0x00)
      else
        draw_line(pixbuf, x, 0, height - 1, 0x80, 0x80, 0x80)
      end
      
      x -= 1
      i -= 1
    end
  end

  def get_label
    "Temperature\nCPU"
  end
  
  def get_tick_per_draw
    4
  end
  
  def discard_data(maxlen)
    if @data.length > maxlen
      @data.slice!(0, @data.length - maxlen)
    end
  end
  
end

