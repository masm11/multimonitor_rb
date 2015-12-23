all:
	gem build multimonitor.gemspec

install: all
	gem install ./multimonitor-1.2.1.gem
