all:
	gem build multimonitor.gemspec

install: all
	gem install ./multimonitor-1.1.0.gem
