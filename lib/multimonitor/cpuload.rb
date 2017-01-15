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

require 'multimonitor/draw'
require 'multimonitor/color'
require 'multimonitor/device_base'

class CPULoad < DeviceBase
  NDATA = 10
  
  def initialize(dev, width)
    super(width, -1)
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
    
    push_data(load)
  end
  
  def draw_1(draw)
    width = draw.width
    height = draw.height
    
    draw.shift
    
    x = width - 1
    
    load = get_last_data
    if load >= 0
      len = load * height;
      
      draw.line(x, 0, height - 1, COLOR_BG)
      if load > 0
        draw.line(x, height - len, height - 1, COLOR_NORMAL)
      end
    else
      draw.line(x, 0, height - 1, COLOR_NODATA)
    end
  end

  def get_label
    "CPU Load\nCPU #{@dev}"
  end
  
  def get_tick_per_draw
    1
  end
  
  def get_tooltip_text
    load = get_last_data
    return nil unless load >= 0
    sprintf('%.1f%%', load * 100)
  end
end
