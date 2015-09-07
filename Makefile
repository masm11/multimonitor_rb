all:
	gem build multimonitor.gemspec

install: all
	gem install ./multimonitor-1.0.2.gem
