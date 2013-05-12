default.git.source.tap do |s|
  s.root    = node[:source] && node[:source][:root] || '/usr/local'
  s.version = '1.8.2.3'
  s.url     = "https://git-core.googlecode.com/files/git-#{node.git.source.version}.tar.gz"
  s.man.url = "https://git-core.googlecode.com/files/git-manpages-#{node.git.source.version}.tar.gz"

  s.configure_options = %w(
    --with-curl
    --with-expat
    --with-libpcre
    --with-openssl
    --without-tcltk
  )
end
