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

def clip(val, min, max)
  val = min if val < min
  val = max if val > max
  val
end

def draw_line(pixbuf, x, y1, y2, r, g, b)
#  p 'draw_line'
  rowstride = pixbuf.rowstride
  pixels = pixbuf.pixels;
  
  y1 = y1.to_i
  y2 = y2.to_i
  if y1 > y2
    t = y1
    y1 = y2
    y2 = t
  end
  x = clip(x, 0, pixbuf.width - 1)
  y1 = clip(y1, 0, pixbuf.height - 1)
  y2 = clip(y2, 0, pixbuf.height - 1)
  
  for y in y1..y2
    p = y * rowstride + x * 3
    pixels[p..p+2] = [ r, g, b ].pack('C3')
  end
  
#  pixels[0] = "\x00"
#  pixels[1] = "\x00"
#  pixels[2] = "\x00"
  pixbuf.pixels = pixels
#  p pixbuf.pixels
end

def draw_shift(pixbuf)
  pixels = pixbuf.pixels
  overflow = pixels[0..2]
  pixels[0..2] = ''
  pixels[pixels.length..pixels.length + 2] = overflow
  pixbuf.pixels = pixels
end

def draw_clear(pixbuf)
  width = pixbuf.width
  height = pixbuf.height
  rowstride = pixbuf.rowstride
  pixels = pixbuf.pixels;
  
  for y in 0...height
    for x in 0...width
      ofs = y * rowstride + x * 3
      pixels[ofs..ofs+2] = [0x80, 0x80, 0x80].pack('C3')
    end
  end
  
  pixbuf.pixels = pixels
end
