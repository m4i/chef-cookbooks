include_recipe 'ruby-build'
include_recipe 'ruby::depends'

ruby_build = node.ruby['ruby-build']

execute "ruby-build #{ruby_build.version} #{ruby_build.prefix}" do
  not_if { ::File.exists?(ruby_build.prefix) }
end

gem_package 'bundler' do
  gem_binary "#{ruby_build.prefix}/bin/gem"
end

chruby_use_path = '/etc/profile.d/chruby_use.sh'
if ruby_build.system_chruby
  template chruby_use_path do
    mode 0644
  end
else
  file chruby_use_path do
    action :delete
  end
end

node.default.ruby.prefix = ruby_build.prefix
