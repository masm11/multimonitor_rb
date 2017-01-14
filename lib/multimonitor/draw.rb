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

require 'gtk3'
require 'multimonitor/color'

class Draw
  
  def initialize(width, height)
    @width = width
    @height = height
    @data = Array.new(row_stride * @height, 0)
  end
  
  def line(x, y1, y2, color)
    rowstride = row_stride
    
    y1 = y1.to_i
    y2 = y2.to_i
    y1, y2 = y2, y1 if y1 > y2
    
    x = clip(x, 0, @width - 1)
    y1 = clip(y1, 0, @height - 1)
    y2 = clip(y2, 0, @height - 1)
    
    i = y1 * rowstride + x * 3
    for y in y1..y2
      @data[i..i+2] = color
      i += rowstride
    end
  end
  
  def shift
    @data.rotate!(3)
  end
  
  def clear
    rowstride = row_stride
    
    for y in 0...height
      i = y * rowstride
      for x in 0...width
        @data[i..i+2] = COLOR_NODATA
        i += 3
      end
    end
  end
  
  def create_pixbuf
    GdkPixbuf::Pixbuf.new(data: @data.pack('C*'),
                          colorspace: :rgb,
                          has_alpha: false,
                          bits_per_sample: 8,
                          width: @width,
                          height: @height,
                          row_stride: row_stride)
  end
  
  def width
    @width
  end
  
  def height
    @height
  end
  
  private
  def clip(val, min, max)
    val = min if val < min
    val = max if val > max
    val
  end
  
  def row_stride
    @width * 3
  end

end
