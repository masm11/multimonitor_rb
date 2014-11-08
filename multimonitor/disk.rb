#!/usr/bin/env ruby
# coding: utf-8

require './multimonitor/draw'

class Disk
  def initialize(dev)
    @data = []
    @dev = dev
    @oldr = 0
    @oldw = 0
  end
  
  def read_data
    h = nil
    
    begin
      File::open("/proc/diskstats") do |f|
        f.each_line do |line|
          dat = line.split
          if dat[2] == @dev
            curr = dat[5].to_i
            curw = dat[9].to_i
            h = {}
            h['r'] = (curr - @oldr) * 512
            h['w'] = (curw - @oldw) * 512
            @oldr = curr
            @oldw = curw
          end
        end
      end
    rescue => e
      p e
    end
    
    # 最初のデータはゴミなので捨てる。
    unless @read_flag
      @read_flag = true
      h = nil
    end
    
    @data << h
  end
  
  def draw_1(pixbuf)
    width = pixbuf.width
    height = pixbuf.height
    
    max = 1024
    for h in @data
      if h
        if max < h['r']
          max = h['r']
        end
        if max < h['w']
          max = h['w']
        end
      end
    end
    max = (Math.log(max) / Math.log(1024)).ceil
    
    if @max != max
      draw_all(pixbuf)
      return
    end
    
    draw_shift(pixbuf)
    
    i = @data.length - 1
    x = width - 1
    
    if i >= 0 && @data[i]
      h = @data[i]
      
      r = h['r']
      w = h['w']
      r = 1 if r < 1
      w = 1 if w < 1
      
      len_r = (Math.log(r) / Math.log(1024)) * height / max / 2
      len_w = (Math.log(w) / Math.log(1024)) * height / max / 2
      
      draw_line(pixbuf, x, 0, height - 1, 0, 0, 0)
      draw_line(pixbuf, x, height / 2 - len_w, height / 2, 0xff, 0x00, 0x00)
      draw_line(pixbuf, x, height / 2, height / 2 + len_r, 0x00, 0xff, 0x00)
      
      for yy in -max + 1 .. max - 1
        y = yy * height / max / 2 + height / 2
        draw_line(pixbuf, x, y, y, 0x80, 0x80, 0x80)
      end
    else
      draw_line(pixbuf, x, 0, height - 1, 0x80, 0x80, 0x80)
    end
  end
  
  def draw_all(pixbuf)
    width = pixbuf.width
    height = pixbuf.height
    
    max = 1024
    for h in @data
      if h
        if max < h['r']
          max = h['r']
        end
        if max < h['w']
          max = h['w']
        end
      end
    end
    max = (Math.log(max) / Math.log(1024)).ceil
    @max = max
    
    i = @data.length - 1
    x = width - 1
    while x >= 0
      if i >= 0 && @data[i]
        h = @data[i]
        
        r = h['r']
        w = h['w']
        r = 1 if r < 1
        w = 1 if w < 1
        
        len_r = (Math.log(r) / Math.log(1024)) * height / max / 2
        len_w = (Math.log(w) / Math.log(1024)) * height / max / 2
        
        draw_line(pixbuf, x, 0, height - 1, 0, 0, 0)
        draw_line(pixbuf, x, height / 2 - len_w, height / 2, 0xff, 0x00, 0x00)
        draw_line(pixbuf, x, height / 2, height / 2 + len_r, 0x00, 0xff, 0x00)

        for yy in -max + 1 .. max - 1
          y = yy * height / max / 2 + height / 2
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
    "Disk\n#{@dev}"
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

