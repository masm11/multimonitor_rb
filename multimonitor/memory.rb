#!/usr/bin/env ruby

require_relative 'draw'

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
  
  def draw_1(pixbuf)
    width = pixbuf.width
    height = pixbuf.height
    
    draw_shift(pixbuf)
    
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
      
      draw_line(pixbuf, x, 0, height - 1, 0, 0, 0)
      draw_line(pixbuf, x, height - alen, height - 1, 0xff, 0x00, 0x00)
      draw_line(pixbuf, x, height - blen, height - 1, 0x80, 0x40, 0x00)
      draw_line(pixbuf, x, height - clen, height - 1, 0x80, 0x00, 0x00)
      draw_line(pixbuf, x, height - klen, height - 1, 0xff, 0x80, 0x80)
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
        
        draw_line(pixbuf, x, 0, height - 1, 0, 0, 0)
        draw_line(pixbuf, x, height - alen, height - 1, 0xff, 0x00, 0x00)
        draw_line(pixbuf, x, height - blen, height - 1, 0x80, 0x40, 0x00)
        draw_line(pixbuf, x, height - clen, height - 1, 0x80, 0x00, 0x00)
        draw_line(pixbuf, x, height - klen, height - 1, 0xff, 0x80, 0x80)
      else
        draw_line(pixbuf, x, 0, height - 1, 0x80, 0x80, 0x80)
      end
      
      x -= 1
      i -= 1
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

