unless platform?('ubuntu')
  raise "#{node.platform} is not supported by the #{cookbook_name}::#{recipe_name} recipe"
end

source 'ruby-build' do
  action  node['ruby-build'].source[:action]
  build   false
  install command: './install.sh', environment: { 'PREFIX' => '%{prefix}' }
end
