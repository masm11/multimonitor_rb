require 'mkmf'

pkg_config('gobject-introspection-1.0')
pkg_config('libmatepanelapplet-4.0')

require 'gobject-introspection'

$LOAD_PATH.each do |dir|
  if /\/extensions\// =~ dir
    $INCFLAGS << " -I#{dir}"
  end
end

create_makefile('mpa')
