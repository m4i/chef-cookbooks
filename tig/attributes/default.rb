default.tig.source.tap do |s|
  s.index_url = 'http://jonas.nitro.dk/tig/releases/'

  unless node.tig.source[:version]
    s.version = LatestVersion.html(url: node.tig.source.index_url)
  end
  s.url = "#{node.tig.source.index_url}tig-#{node.tig.source.version}.tar.gz"

  s.install_doc = false
end
