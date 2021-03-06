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

require 'multimonitor/draw'
require 'multimonitor/color'

class Swap
  def initialize(dev)
    @data = []
    @dev = dev
    @size = -1
    
    begin
      File::open("/proc/swaps") do |f|
        f.each_line do |line|
          dat = line.split
          if dat[0] == @dev
            @size = dat[2].to_i
          end
        end
      end
    rescue => e
      p e
      h = nil
    end
  end
  
  def read_data
    used = -1
    begin
      File::open("/proc/swaps") do |f|
        f.each_line do |line|
          dat = line.split
          if dat[0] == @dev
            used = dat[3].to_i
          end
        end
      end
    rescue => e
      p e
    end
    
    @data << used
  end
  
  def draw_1(pixbuf)
    width = pixbuf.width
    height = pixbuf.height
    
    draw_shift(pixbuf)
    
    i = @data.length - 1
    x = width - 1
    
    if @size > 0 && i >= 0 && @data[i] >= 0
      used = @data[i]
      
      len = height * used / @size
      
      draw_line(pixbuf, x, 0, height - 1, COLOR_BG)
      if used > 0
        draw_line(pixbuf, x, height - len, height - 1, COLOR_NORMAL)
      end
    else
      draw_line(pixbuf, x, 0, height - 1, COLOR_NODATA)
    end
  end

  def get_label
    "Swap\n#{@dev}"
  end
  
  def get_tick_per_draw
    4
  end
  
  def discard_data(maxlen)
    if @data.length > maxlen
      @data.slice!(0, @data.length - maxlen)
    end
  end

  def size_text(size)
    return sprintf('%.1fGB', size / 1024.0 / 1024) if size >= 1024 * 1024
    return sprintf('%.1fMB', size / 1024.0) if size >= 1024
    return sprintf('%dKB', size)
  end
  
  def get_tooltip_text
    used = @data[@data.length - 1]
    return nil unless used >= 0
    size_text(used)
  end
end

