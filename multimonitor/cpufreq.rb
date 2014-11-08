#!/usr/bin/env ruby

require './multimonitor/draw'

class CPUFreq
  def initialize(dev)
    @data = []
    @dev = dev

    @max_freq = -1
    
    begin
      File::open("/sys/devices/system/cpu/cpu#{@dev}/cpufreq/scaling_max_freq") do |f|
        f.each_line do |line|
          @max_freq = line.to_i
        end
      end
    rescue => e
      #    p e
    end
  end
  
  def read_data
    freq = -1
    
    begin
      File::open("/sys/devices/system/cpu/cpu#{@dev}/cpufreq/scaling_cur_freq") do |f|
        f.each_line do |line|
          freq = line.to_i
        end
      end
    rescue => e
      #    p e
    end
    
    @data << freq
  end
  
  def draw_1(pixbuf)
    width = pixbuf.width
    height = pixbuf.height
    
    draw_shift(pixbuf)
    
    i = @data.length - 1
    x = width - 1
    
    if @max_freq > 0 && i >= 0 && @data[i] > 0
      freq = @data[i]
      
      len = freq * height / @max_freq
      
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
      if @max_freq > 0 && i >= 0 && @data[i] > 0
        freq = @data[i]
#        p freq
        
        len = freq * height / @max_freq
        
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
    "CPU Freq\nCPU #{@dev}"
  end
  
  def get_tick_per_draw
    1
  end
  
  def discard_data(maxlen)
    if @data.length > maxlen
      @data.slice!(0, @data.length - maxlen)
    end
  end
  
end

