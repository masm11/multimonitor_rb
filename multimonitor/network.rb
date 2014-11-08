#!/usr/bin/env ruby
# coding: utf-8

require './multimonitor/draw'

class Network
  def initialize(dev)
    @data = []
    @dev = dev
    @oldrx = 0
    @oldtx = 0
  end
  
  def read_data
    h = nil
    rx = 0
    tx = 0
    new_rx = 0
    new_tx = 0
    up = false
    
    begin
      File::open("/sys/class/net/#{@dev}/statistics/rx_bytes") do |f|
        f.each_line do |line|
          new_rx = line.to_i
        end
      end
      File::open("/sys/class/net/#{@dev}/statistics/tx_bytes") do |f|
        f.each_line do |line|
          new_tx = line.to_i
        end
      end
      begin
        File::open("/sys/class/net/#{@dev}/carrier") do |f|
          f.each_line do |line|
            up = (line.to_i != 0)
          end
        end
      rescue Errno::EINVAL
        # NOP
      end
      
      rx = new_rx - @oldrx
      tx = new_tx - @oldtx
      @oldrx = new_rx
      @oldtx = new_tx
      
      h = {}
      h['rx'] = rx * 8
      h['tx'] = tx * 8
      h['up'] = up
    rescue => e
#      p e
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
        if max < h['rx']
          max = h['rx']
        end
        if max < h['tx']
          max = h['tx']
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
      
      rx = h['rx']
      tx = h['tx']
      rx = 1 if rx < 1
      tx = 1 if tx < 1
      
      len_rx = (Math.log(rx) / Math.log(1024)) * height / max / 2
      len_tx = (Math.log(tx) / Math.log(1024)) * height / max / 2
      
      if h['up']
        draw_line(pixbuf, x, 0, height - 1, 0, 0, 0)
      else
        draw_line(pixbuf, x, 0, height - 1, 0x80, 0x80, 0x80)
      end
      draw_line(pixbuf, x, height / 2 - len_tx, height / 2, 0xff, 0x00, 0x00)
      draw_line(pixbuf, x, height / 2, height / 2 + len_rx, 0x00, 0xff, 0x00)
      
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
        if max < h['rx']
          max = h['rx']
        end
        if max < h['tx']
          max = h['tx']
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
        
        rx = h['rx']
        tx = h['tx']
        rx = 1 if rx < 1
        tx = 1 if tx < 1
        
        len_rx = (Math.log(rx) / Math.log(1024)) * height / max / 2
        len_tx = (Math.log(tx) / Math.log(1024)) * height / max / 2
        
        draw_line(pixbuf, x, 0, height - 1, 0, 0, 0)
        draw_line(pixbuf, x, height / 2 - len_tx, height / 2, 0xff, 0x00, 0x00)
        draw_line(pixbuf, x, height / 2, height / 2 + len_rx, 0x00, 0xff, 0x00)

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
    "Network\n#{@dev}"
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

