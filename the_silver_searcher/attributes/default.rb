default.the_silver_searcher.source.tap do |s|
  s.github = 'ggreer/the_silver_searcher'
  unless node.the_silver_searcher.source[:version]
    s.version = LatestVersion.github(name: node.the_silver_searcher.source.github)
  end

  # 0.14 は prefix の指定ができない。
  # 0.15 がリリースされたら削除
  if Gem::Version.new(node.the_silver_searcher.source.version) <
     Gem::Version.new('0.15')
    s.use_git    = true
    s.version    = '0.15pre-3c78a4a'
    s.git_commit = '3c78a4a8920fdfdf21f910d75db40f5c49dd90bd'
  end
end
