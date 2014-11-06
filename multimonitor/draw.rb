#!/usr/bin/env ruby

def draw_line(pixbuf, x, y1, y2, r, g, b)
#  p 'draw_line'
  rowstride = pixbuf.rowstride
  pixels = pixbuf.pixels;
  
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
