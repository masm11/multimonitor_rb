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
require 'multimonitor/device_base'

class Battery < DeviceBase
  def initialize(dev, width)
    super(width, nil)
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
    
    push_data(h)
  end
  
  def draw_1(draw)
    width = draw.width
    height = draw.height
    
    draw.shift
    
    x = width - 1
    
    h = get_last_data
    if h
      len = h['capacity'] * height / 100
      
      if h['charging']
        draw.line(x, 0, height - 1, COLOR_BG_CHARGE)
        if len > 0
          draw.line(x, height - len, height - 1, COLOR_CHARGE)
        end
      else
        draw.line(x, 0, height - 1, COLOR_BG)
        if len > 0
          draw.line(x, height - len, height - 1, COLOR_NORMAL)
        end
      end
    else
      draw.line(x, 0, height - 1, COLOR_NODATA)
    end
  end
  
  def get_label
    "Battery\nBAT #{@dev}"
  end
  
  def get_tick_per_draw
    16
  end
  
  def get_tooltip_text
    h = get_last_data
    return nil unless h
    sprintf("%d%%\n%scharging",
            h['capacity'],
            h['charging'] ? '' : 'dis')
  end
end

