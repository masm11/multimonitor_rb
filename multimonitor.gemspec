Gem::Specification.new do |s|
  s.name	= 'multimonitor'
  s.version	= '1.2.1'
  s.summary	= "Multi Monitor"
  s.description	= 'Status monitor of multiple devices.'
  s.authors	= ['Yuuki Harano']
  s.email	= 'masm@masm11.ddo.jp'
  s.files	= [ 'README', 'COPYING',
                    'bin/multimonitor',
                    'lib/multimonitor/battery.rb',
                    'lib/multimonitor/color.rb',
                    'lib/multimonitor/cpufreq.rb',
                    'lib/multimonitor/cpuload.rb',
                    'lib/multimonitor/disk.rb',
                    'lib/multimonitor/draw.rb',
                    'lib/multimonitor/loadavg.rb',
                    'lib/multimonitor/memory.rb',
                    'lib/multimonitor/network.rb',
                    'lib/multimonitor/swap.rb',
                    'lib/multimonitor/temp.rb',
                    'lib/multimonitor/rfkill.rb' ]
  s.executables	<< 'multimonitor'
  s.homepage	= 'https://github.com/masm11/multimonitor'
  s.license	= 'GPL'
  s.add_runtime_dependency 'gtk3', '~> 3.0', '>= 3.0.7'
  s.add_runtime_dependency 'network_interface', '~> 0.0', '>= 0.0.1'
end
