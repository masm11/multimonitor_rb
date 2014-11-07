#!/usr/bin/env ruby

require './multimonitor/draw'

class LoadAvg
  def initialize(dev)
    @data = []
    @dev = dev
  end
  
  def read_data
    loadavg = -1
    
    begin
      File::open("/proc/loadavg") do |f|
        f.each_line do |line|
          dat = line.split
          case @dev
          when '1'
            loadavg = dat[0].to_f
          when '5'
            loadavg = dat[1].to_f
          when '15'
            loadavg = dat[2].to_f
          end
        end
      end
    rescue => e
      #    p e
    end
    
    @data << loadavg
  end
  
  def calc_max
    max = 1.0
    for i in 0...@data.length
      if @data[i] > max
        max = @data[i]
      end
    end
    
    max.ceil
  end
  
  def draw_1(pixbuf)
    width = pixbuf.width
    height = pixbuf.height

    max = calc_max
    if max != @oldmax
      draw_all(pixbuf)
      return
    end
    
    draw_shift(pixbuf)
    
    i = @data.length - 1
    x = width - 1
    
    if i >= 0 && @data[i] > 0
      loadavg = @data[i]
      
      len = loadavg * height / max
      
      draw_line(pixbuf, x, 0, height - 1, 0, 0, 0)
      draw_line(pixbuf, x, height - len, height - 1, 0xff, 0x00, 0x00)
      
      for h in 1...max
        y = h * height / max
        draw_line(pixbuf, x, y, y, 0xff, 0xff, 0xff)
      end
    else
      draw_line(pixbuf, x, 0, height - 1, 0x80, 0x80, 0x80)
    end
  end
  
  def draw_all(pixbuf)
    width = pixbuf.width
    height = pixbuf.height

    max = calc_max
    @old_max = max
    
    i = @data.length - 1
    x = width - 1
    
    while x >= 0
      if i >= 0 && @data[i] > 0
        loadavg = @data[i]
        
        len = loadavg * height / max
        
        draw_line(pixbuf, x, 0, height - 1, 0, 0, 0)
        draw_line(pixbuf, x, height - len, height - 1, 0xff, 0x00, 0x00)

        for h in 1...max
          y = h * height / max
          draw_line(pixbuf, x, y, y, 0xff, 0xff, 0xff)
        end
      else
        draw_line(pixbuf, x, 0, height - 1, 0x80, 0x80, 0x80)
      end
      
      x -= 1
      i -= 1
    end
  end

  def get_label
    "Loadavg\n#{@dev}min"
  end
  
  def get_tick_per_draw
    16
  end
  
end

