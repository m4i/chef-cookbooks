default['ruby-build'].tap do |d|
  d.default_recipe = 'package'
end

default['ruby-build'].source.tap do |s|
  s.root = node[:source] && node[:source][:root] || '/usr/local'

  s.git.version   = '20130501'
  s.git.reference = "v#{node['ruby-build'].source.git.version}"
  s.git.url       = 'https://github.com/sstephenson/ruby-build.git'
end
