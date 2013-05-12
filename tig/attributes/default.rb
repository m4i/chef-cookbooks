default.tig.source.tap do |s|
  s.root        = node[:source] && node[:source][:root] || '/usr/local'
  s.version     = '1.1'
  s.url         = "http://jonas.nitro.dk/tig/releases/tig-#{node.tig.source.version}.tar.gz"
  s.install_doc = false
end
