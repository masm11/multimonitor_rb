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

class Temp
  def initialize(dev)
    @dev = dev
    @id1, @id2n, @id3 = dev.split('-')

    @data = []
    @max = nil
    @id2 = -1
    
    begin
      Dir.glob("/sys/devices/platform/coretemp.#{@id1}/hwmon/hwmon*") do |dir|
        File.open("#{dir}/name") do |f|
          f.each_line do |line|
            line.chomp!
            if line == @id2n
              if /(\d+)$/ =~ dir
                @id2 = $1
              end
            end
          end
        end
      end

      File::open("/sys/devices/platform/coretemp.#{@id1}/hwmon/hwmon#{@id2}/temp#{@id3}_max") do |f|
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
      File::open("/sys/devices/platform/coretemp.#{@id1}/hwmon/hwmon#{@id2}/temp#{@id3}_input") do |f|
        f.each_line do |line|
          temp = line.to_i / 1000.0
        end
      end
    rescue => e
      # p e
    end
    
    @data << temp
  end
  
  def draw_1(draw)
    width = draw.width
    height = draw.height
    
    draw.shift
    
    i = @data.length - 1
    x = width - 1
    
    if @max && i >= 0 && @data[i]
      temp = @data[i]
      
      len = height * temp / @max
      
      draw.line(x, 0, height - 1, COLOR_BG)
      draw.line(x, height - len, height - 1, COLOR_NORMAL)
    else
      draw.line(x, 0, height - 1, COLOR_NODATA)
    end
  end

  def get_label
    "Temperature\n#{@id1}-#{@id2}-#{@id3}"
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
    sprintf('%.1f℃', temp)  # ℃ is U+2103
  end
end

