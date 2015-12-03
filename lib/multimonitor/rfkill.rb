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

class RfKill
  def initialize(n)
    @n = n
    @data = []
  end
  
  def read_data
    h = {}
    
    begin
      File::open("/sys/class/rfkill/rfkill#{@n}/hard") do |f|
        f.each_line do |line|
          h[:hard] = line.to_i != 0
        end
      end
      
      File::open("/sys/class/rfkill/rfkill#{@n}/soft") do |f|
        f.each_line do |line|
          h[:soft] = line.to_i != 0
        end
      end
      
      File::open("/sys/class/rfkill/rfkill#{@n}/state") do |f|
        f.each_line do |line|
          h[:state] = line.to_i != 0
        end
      end

    rescue => e
      p e
      h = nil
    end
    
    @data << h
  end
  
  def draw_1(pixbuf)
    width = pixbuf.width
    height = pixbuf.height
    
    draw_shift(pixbuf)
    
    i = @data.length - 1
    x = width - 1
    
    if i >= 0 && @data[i]
      h = @data[i]
      
      if h[:hard]
        color = COLOR_HARD
      elsif h[:soft]
        color = COLOR_SOFT
      elsif !h[:state]
        color = COLOR_STATE
      else
        color = COLOR_BG
      end
      
      draw_line(pixbuf, x, 0, height - 1, color)
    else
      draw_line(pixbuf, x, 0, height - 1, COLOR_NODATA)
    end
  end

  def get_label
    "RfKill\n#{@n}"
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
    h = @data[@data.length - 1]
    return nil unless h
    sprintf("Hard:%s\nSoft:%s\nState:%s",
            h[:hard], h[:soft], h[:state])
  end
end

