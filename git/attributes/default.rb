default.git.source.tap do |s|
  unless node.git.source[:version]
    s.version = LatestVersion.google_code(name: 'git-core')
  end
  s.url     = "https://git-core.googlecode.com/files/git-#{node.git.source.version}.tar.gz"
  s.man_url = "https://git-core.googlecode.com/files/git-manpages-#{node.git.source.version}.tar.gz"

  s.configure_options = %w(
    --with-curl
    --with-expat
    --with-libpcre
    --with-openssl
    --without-tcltk
  )
end
