default['ruby-build'].tap do |d|
  d.default_recipe = 'package'
end

default['ruby-build'].source.tap do |s|
  s.github = 'sstephenson/ruby-build'
  unless node['ruby-build'].source[:version]
    s.version = LatestVersion.github(name: node['ruby-build'].source.github)
  end
  s.git_tag = "v#{node['ruby-build'].source.version}"
end
