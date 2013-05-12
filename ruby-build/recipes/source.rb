unless platform?('ubuntu')
  raise "#{node.platform} is not supported by the #{cookbook_name}::#{recipe_name} recipe"
end

source 'ruby-build' do
  action          :install
  install_command 'PREFIX=%{prefix} paco -D ./install.sh'
end
