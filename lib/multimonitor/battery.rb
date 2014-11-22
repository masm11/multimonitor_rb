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

class Battery
  def initialize(dev)
    @data = []
    @dev = dev
  end
  
  def read_data
    h = nil
    
    begin
      cap = -1
      charging = false
      
      File::open("/sys/class/power_supply/BAT#{@dev}/capacity") do |f|
        f.each_line do |line|
          cap = line.to_i
        end
      end
      
      File::open("/sys/class/power_supply/BAT#{@dev}/status") do |f|
        f.each_line do |line|
          if /^Charging/ =~ line
            charging = true
          end
        end
      end
      
      #    p cap
      #    p charging
      h = {
        'capacity' => cap,
        'charging' => charging,
      }
    rescue => e
      #    p e
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
      
      len = h['capacity'] * height / 100
      
      if h['charging']
        draw_line(pixbuf, x, 0, height - 1, COLOR_BG_CHARGE)
        draw_line(pixbuf, x, height - len, height - 1, COLOR_CHARGE)
      else
        draw_line(pixbuf, x, 0, height - 1, COLOR_BG)
        draw_line(pixbuf, x, height - len, height - 1, COLOR_NORMAL)
      end
    else
      draw_line(pixbuf, x, 0, height - 1, COLOR_NODATA)
    end
  end
  
  def get_label
    "Battery\nBAT #{@dev}"
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
    h = @data[@data.length - 1]
    return nil unless h
    sprintf("%d%%\n%scharging",
            h['capacity'],
            h['charging'] ? '' : 'dis')
  end
end

