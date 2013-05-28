unless platform?('ubuntu')
  raise "#{node.platform} is not supported by the #{cookbook_name}::#{recipe_name} recipe"
end

include_recipe 'build-essential'

source 'chruby' do
  action  node.chruby.source[:action]
  build   false
  install command: 'make install', environment: { 'PREFIX' => '%{prefix}' }
end

template '/etc/profile.d/chruby.sh' do
  mode 0644
end
