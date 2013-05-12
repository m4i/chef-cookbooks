include_recipe 'ruby::depends'

source 'ruby' do
  action :install
end

gem_package 'bundler' do
  gem_binary "#{node.ruby.source.root}/bin/gem"
end

node.default.ruby.prefix = node.ruby.source.prefix
