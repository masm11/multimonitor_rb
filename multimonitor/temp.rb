#!/usr/bin/env ruby

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
require_relative 'color'

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
      
      draw_line(pixbuf, x, 0, height - 1, COLOR_BG)
      draw_line(pixbuf, x, height - len, height - 1, COLOR_NORMAL)
    else
      draw_line(pixbuf, x, 0, height - 1, COLOR_NODATA)
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

  def get_tooltip_text
    temp = @data[@data.length - 1]
    return nil unless temp
    sprintf('%.1fC', temp)
  end
end

