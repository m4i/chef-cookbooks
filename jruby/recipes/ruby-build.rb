include_recipe 'ruby-build'

ruby_build = node.jruby['ruby-build']

execute "ruby-build #{ruby_build.version} #{ruby_build.prefix}" do
  not_if { ::File.exists?(ruby_build.prefix) }
end

gem_package 'bundler' do
  gem_binary "#{ruby_build.prefix}/bin/gem"
end
