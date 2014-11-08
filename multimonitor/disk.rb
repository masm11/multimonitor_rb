#!/usr/bin/env ruby
# coding: utf-8

# Multi Monitor - shows graphs of multiple device informations
# Copyright (C) 2014 Yuuki Harano
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require_relative 'draw'

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
  
  def bps_text(bps)
    return sprintf('%.1fGB/s', bps / 1000000000.0) if bps >= 1000000000
    return sprintf('%.1fMB/s', bps / 1000000.0) if bps >= 1000000
    return sprintf('%.1fKB/s', bps / 1000.0) if bps >= 1000
    return sprintf('%.1fB/s', bps)
  end
  
  def get_tooltip_text
    h = @data[@data.length - 1]
    return nil unless h
    sprintf("Write:%s\nRead:%s",
            bps_text(h['w']), bps_text(h['r']))
  end
end

