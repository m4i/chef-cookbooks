default.chruby.source.tap do |s|
  s.github = 'postmodern/chruby'
  unless node.chruby.source[:version]
    s.version = LatestVersion.github(name: node.chruby.source.github)
  end
  s.git_tag = "v#{node.chruby.source.version}"
end
