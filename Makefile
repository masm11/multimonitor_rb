all:
	gem build multimonitor.gemspec

install: all
	gem install ./multimonitor-`ruby -e 'require "./lib/multimonitor/version"; print VERSION'`.gem
