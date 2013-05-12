default.the_silver_searcher.source.tap do |s|
  s.root    = node[:source] && node[:source][:root] || '/usr/local'
  s.version = '0.15'
  s.url     = "https://github.com/ggreer/the_silver_searcher/archive/#{node.the_silver_searcher.source.version}.tar.gz"

  # 0.14 は prefix の指定ができない。
  # 0.15 がリリースされたら削除
  s.git.reference = '3c78a4a8920fdfdf21f910d75db40f5c49dd90bd'
  s.git.url       = 'https://github.com/ggreer/the_silver_searcher.git'
end
