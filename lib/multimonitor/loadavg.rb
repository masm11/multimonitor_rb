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
    
    if i >= 0 && @data[i] >= 0
      loadavg = @data[i]
      
      len = loadavg * height / max
      
      draw_line(pixbuf, x, 0, height - 1, COLOR_BG)
      draw_line(pixbuf, x, height - len, height - 1, COLOR_NORMAL)
      
      for h in 1...max
        y = h * height / max
        draw_line(pixbuf, x, y, y, COLOR_LINE)
      end
    else
      draw_line(pixbuf, x, 0, height - 1, COLOR_NODATA)
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
      if i >= 0 && @data[i] >= 0
        loadavg = @data[i]
        
        len = loadavg * height / max
        
        draw_line(pixbuf, x, 0, height - 1, COLOR_BG)
        draw_line(pixbuf, x, height - len, height - 1, COLOR_NORMAL)

        for h in 1...max
          y = h * height / max
          draw_line(pixbuf, x, y, y, COLOR_LINE)
        end
      else
        draw_line(pixbuf, x, 0, height - 1, COLOR_NODATA)
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
  
  def discard_data(maxlen)
    if @data.length > maxlen
      @data.slice!(0, @data.length - maxlen)
    end
  end
  
  def get_tooltip_text
    loadavg = @data[@data.length - 1]
    return nil unless loadavg >= 0
    sprintf('%.1f%%', loadavg * 100)
  end
end

