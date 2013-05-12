unless platform?('ubuntu')
  raise "#{node.platform} is not supported by the #{cookbook_name}::#{recipe_name} recipe"
end

include_recipe 'build-essential'

source 'chruby' do
  action          :install
  install_command 'PREFIX=%{prefix} paco -D make install'
end

template '/etc/profile.d/chruby.sh' do
  mode 0644
end
