default.chruby.source.tap do |s|
  s.root    = node[:source] && node[:source][:root] || '/usr/local'
  s.version = '0.3.4'
  s.url     = "https://github.com/postmodern/chruby/archive/v#{node.chruby.source.version}.tar.gz"
end
