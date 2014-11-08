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

class CPUFreq
  def initialize(dev)
    @data = []
    @dev = dev

    @max_freq = -1
    
    begin
      File::open("/sys/devices/system/cpu/cpu#{@dev}/cpufreq/scaling_max_freq") do |f|
        f.each_line do |line|
          @max_freq = line.to_i
        end
      end
    rescue => e
      #    p e
    end
  end
  
  def read_data
    freq = -1
    
    begin
      File::open("/sys/devices/system/cpu/cpu#{@dev}/cpufreq/scaling_cur_freq") do |f|
        f.each_line do |line|
          freq = line.to_i
        end
      end
    rescue => e
      #    p e
    end
    
    @data << freq
  end
  
  def draw_1(pixbuf)
    width = pixbuf.width
    height = pixbuf.height
    
    draw_shift(pixbuf)
    
    i = @data.length - 1
    x = width - 1
    
    if @max_freq > 0 && i >= 0 && @data[i] > 0
      freq = @data[i]
      
      len = freq * height / @max_freq
      
      draw_line(pixbuf, x, 0, height - 1, 0, 0, 0)
      draw_line(pixbuf, x, height - len, height - 1, 0xff, 0x00, 0x00)
    else
      draw_line(pixbuf, x, 0, height - 1, 0x80, 0x80, 0x80)
    end
  end
  
  def draw_all(pixbuf)
    width = pixbuf.width
    height = pixbuf.height
    
    i = @data.length - 1
    x = width - 1
    while x >= 0
      if @max_freq > 0 && i >= 0 && @data[i] > 0
        freq = @data[i]
#        p freq
        
        len = freq * height / @max_freq
        
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
    "CPU Freq\nCPU #{@dev}"
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
    freq = @data[@data.length - 1]
    return nil unless freq > 0
    if freq >= 1000000
      sprintf('%.1fGHz', freq / 1000000.0)
    else
      sprintf('%dMHz', freq / 1000)
    end
  end
end

