#!/usr/bin/env ruby
# coding: utf-8

require './multimonitor/draw'

class CPULoad
  NDATA = 10
  
  def initialize(dev)
    @data = []
    @dev = dev
    @olddata = []
    for i in 0...NDATA
      @olddata[i] = 0
    end
  end
  
  def read_data
    load = -1

    wanted = "cpu#{@dev}"
    
    begin
      File::open("/proc/stat") do |f|
        f.each_line do |line|
          data = line.split
          if data[0] == wanted
            busy = 0
            idle = 0
            for i in 0...NDATA
              if i != 3
                busy += data[i + 1].to_i - @olddata[i]
              else
                idle += data[i + 1].to_i - @olddata[i]
              end
              @olddata[i] = data[i + 1].to_i
            end
            load = busy / (idle + busy + 0.0)	# +0.0:浮動小数に変換
          end
        end
      end
    rescue => e
#          p e
    end
    
    # 最初のデータはゴミなので捨てる。
    unless @read_flag
      @read_flag = true
      load = -1
    end
    
    @data << load
  end
  
  def draw_1(pixbuf)
    width = pixbuf.width
    height = pixbuf.height
    
    draw_shift(pixbuf)
    
    i = @data.length - 1
    x = width - 1
    
    if i >= 0 && @data[i] >= 0
      load = @data[i]
      
      len = load * height;
      
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
      if i >= 0 && @data[i] > 0
        load = @data[i]
        
        len = load * height
        
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
    "CPU Load\nCPU #{@dev}"
  end
  
  def get_tick_per_draw
    1
  end
  
  def discard_data(maxlen)
    if @data.length > maxlen
      @data.slice!(0, @data.length - maxlen)
    end
  end
  
  def get_tooltip_text
    load = @data[@data.length - 1]
    return nil unless load >= 0
    sprintf('%.1f%%', load * 100)
  end
end
