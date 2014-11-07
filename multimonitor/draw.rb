#!/usr/bin/env ruby

def draw_line(pixbuf, x, y1, y2, r, g, b)
#  p 'draw_line'
  rowstride = pixbuf.rowstride
  pixels = pixbuf.pixels;
  
  for y in y1.to_i..y2.to_i
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
