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
require 'network_interface'

class Network
  def initialize(dev)
    @data = []
    @dev = dev
    @oldrx = 0
    @oldtx = 0
  end
  
  def read_data
    h = nil
    rx = 0
    tx = 0
    new_rx = 0
    new_tx = 0
    up = false
    
    begin
      File::open("/sys/class/net/#{@dev}/statistics/rx_bytes") do |f|
        f.each_line do |line|
          new_rx = line.to_i
        end
      end
      File::open("/sys/class/net/#{@dev}/statistics/tx_bytes") do |f|
        f.each_line do |line|
          new_tx = line.to_i
        end
      end
      begin
        File::open("/sys/class/net/#{@dev}/carrier") do |f|
          f.each_line do |line|
            up = (line.to_i != 0)
          end
        end
      rescue Errno::EINVAL
        # NOP
      end
      
      rx = new_rx - @oldrx
      tx = new_tx - @oldtx
      @oldrx = new_rx
      @oldtx = new_tx
      
      h = {}
      h['rx'] = rx * 8
      h['tx'] = tx * 8
      h['up'] = up
    rescue => e
#      p e
    end
    
    # 最初のデータはゴミなので捨てる。
    unless @read_flag
      @read_flag = true
      h = nil
    end
    
    @data << h
  end
  
  def draw_1(pixbuf)
    width = pixbuf.width
    height = pixbuf.height
    
    max = 1024
    for h in @data
      if h
        if max < h['rx']
          max = h['rx']
        end
        if max < h['tx']
          max = h['tx']
        end
      end
    end
    max = (Math.log(max) / Math.log(1024)).ceil
    
    if @max != max
      draw_all(pixbuf)
      return
    end
    
    draw_shift(pixbuf)
    
    i = @data.length - 1
    x = width - 1
    
    if i >= 0 && @data[i]
      h = @data[i]
      
      rx = h['rx']
      tx = h['tx']
      rx = 1 if rx < 1
      tx = 1 if tx < 1
      
      len_rx = (Math.log(rx) / Math.log(1024)) * height / max / 2
      len_tx = (Math.log(tx) / Math.log(1024)) * height / max / 2
      
      if h['up']
        draw_line(pixbuf, x, 0, height - 1, COLOR_BG)
      else
        draw_line(pixbuf, x, 0, height - 1, COLOR_NODATA)
      end
      draw_line(pixbuf, x, height / 2 - len_tx, height / 2, COLOR_WRITE)
      draw_line(pixbuf, x, height / 2, height / 2 + len_rx, COLOR_READ)
      
      for yy in -max + 1 .. max - 1
        y = yy * height / max / 2 + height / 2
        draw_line(pixbuf, x, y, y, COLOR_LINE)
      end
    else
      draw_line(pixbuf, x, 0, height - 1, COLOR_NODATA)
    end
  end
  
  def draw_all(pixbuf)
    width = pixbuf.width
    height = pixbuf.height
    
    max = 1024
    for h in @data
      if h
        if max < h['rx']
          max = h['rx']
        end
        if max < h['tx']
          max = h['tx']
        end
      end
    end
    max = (Math.log(max) / Math.log(1024)).ceil
    @max = max
    
    i = @data.length - 1
    x = width - 1
    while x >= 0
      if i >= 0 && @data[i]
        h = @data[i]
        
        rx = h['rx']
        tx = h['tx']
        rx = 1 if rx < 1
        tx = 1 if tx < 1
        
        len_rx = (Math.log(rx) / Math.log(1024)) * height / max / 2
        len_tx = (Math.log(tx) / Math.log(1024)) * height / max / 2
        
        draw_line(pixbuf, x, 0, height - 1, COLOR_BG)
        draw_line(pixbuf, x, height / 2 - len_tx, height / 2, COLOR_WRITE)
        draw_line(pixbuf, x, height / 2, height / 2 + len_rx, COLOR_READ)

        for yy in -max + 1 .. max - 1
          y = yy * height / max / 2 + height / 2
          draw_line(pixbuf, x, y, y, COLOR_LINE)
        end
      else
        draw_line(pixbuf, x, 0, height - 1, COLOR_NODATA)
      end
      
      x -= 1
      i -= 1
    end
  end

  def get_label
    "Network\n#{@dev}"
  end
  
  def get_tick_per_draw
    4
  end
  
  def discard_data(maxlen)
    if @data.length > maxlen
      @data.slice!(0, @data.length - maxlen)
    end
  end
  
  def bps_text(bps)
    return sprintf('%.1fGbps', bps / 1000000000.0) if bps >= 1000000000
    return sprintf('%.1fMbps', bps / 1000000.0) if bps >= 1000000
    return sprintf('%.1fKbps', bps / 1000.0) if bps >= 1000
    return sprintf('%.1fbps', bps)
  end

  def netmask_count_bits(n, max)
    for i in 0...max
      if n & (1 << (max - 1 - i)) == 0
        return i
      end
    end
    return max
  end
  
  def netmask_to_prefixlen4(netmask)
    a = netmask.split('.')
    a = a[0].to_i << 24 | a[1].to_i << 16 | a[2].to_i << 8 | a[3].to_i
    netmask_count_bits(a, 32)
  end
  
  def netmask_to_prefixlen6(netmask)
    a = netmask.split(':')
    n = 0
    for i in 0..7
      if a[i] && a[i] != ''
        n |= a[i].hex << ((7 - i) * 16)
      end
    end
    netmask_count_bits(n, 128)
  end
  
  def netmask_to_prefixlen(netmask)
    @plen_cache = {} unless @plen_cache
    if @plen_cache[netmask]
      return @plen_cache[netmask]
    else
      if /:/ =~ netmask
        plen = netmask_to_prefixlen6(netmask)
      else
        plen = netmask_to_prefixlen4(netmask)
      end
      @plen_cache[netmask] = plen
      plen
    end
  end
  
  def get_addresses
    hash = NetworkInterface::addresses(@dev)
    return [] unless hash
    addresses = []
    for family in hash.keys.sort
      mult = hash[family]
      for a in mult
        addr = a['addr']
        addr.sub!(/%.*/, '')
        netmask = a['netmask']
        if netmask
          plen = netmask_to_prefixlen(netmask)
          addresses << addr + '/' + plen.to_s
        else
          addresses << addr
        end
      end
    end
    addresses
  end
  
  def get_tooltip_text
    text = ''
    delim = ''
    for addr in get_addresses
      text += delim + addr
      delim = "\n"
    end
    h = @data[@data.length - 1]
    if h
      text += sprintf("\nTx:%s\nRx:%s", bps_text(h['tx']), bps_text(h['rx']))
    end
    text
  end
end
