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

class Memory
  def initialize
    @data = []
  end
  
  def read_data
    h = {}
    
    begin
      File::open("/proc/meminfo") do |f|
        f.each_line do |line|
          dat = line.split
          case dat[0]
          when 'MemTotal:'
            h['total'] = dat[1].to_i
          when 'MemFree:'
            h['free'] = dat[1].to_i
          when 'Buffers:'
            h['buffers'] = dat[1].to_i
          when 'Cached:'
            h['cached'] = dat[1].to_i
          when 'AnonPages:'
            h['anon'] = dat[1].to_i
          end
        end
      end
      h['kernel'] = h['total'] - h['free'] - h['buffers'] - h['cached'] - h['anon']
    rescue => e
      p e
      h = nil
    end
    
    @data << h
  end
  
  def draw_1(draw)
    width = draw.width
    height = draw.height
    
    draw.shift
    
    i = @data.length - 1
    x = width - 1
    
    if i >= 0 && @data[i]
      h = @data[i]
      
      total = h['total']
      free = h['free']
      buffers = h['buffers']
      cached = h['cached']
      anon = h['anon']
      kernel = h['kernel']
      
      alen = height * (kernel + cached + buffers + anon) / total
      blen = height * (kernel + cached + buffers) / total
      clen = height * (kernel + cached) / total
      klen = height * kernel / total
      
      draw.line(x, 0, height - 1, COLOR_BG)
      draw.line(x, height - alen, height - 1, COLOR_ANON)
      draw.line(x, height - blen, height - 1, COLOR_BUFF)
      draw.line(x, height - clen, height - 1, COLOR_CACHE)
      draw.line(x, height - klen, height - 1, COLOR_KERN)
    else
      draw.line(x, 0, height - 1, COLOR_NODATA)
    end
  end

  def get_label
    "Memory"
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
    h = @data[@data.length - 1]
    return nil unless h
    sprintf("Anon:%s\nBuffers:%s\nCached:%s\nKernel:%s",
            size_text(h['anon']),
            size_text(h['buffers']),
            size_text(h['cached']),
            size_text(h['kernel']))
  end
end

