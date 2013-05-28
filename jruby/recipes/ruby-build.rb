include_recipe 'ruby-build'

ruby_build = node.jruby['ruby-build']

execute "ruby-build #{ruby_build.version} #{ruby_build.prefix}" do
  not_if { ::File.exists?(ruby_build.prefix) }
end

node.default.jruby.prefix = ruby_build.prefix

include_recipe 'jruby::install-basic-gems'
