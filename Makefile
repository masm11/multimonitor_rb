all:
	gem build multimonitor.gemspec

install: all
	gem install ./multimonitor-1.2.0.gem
