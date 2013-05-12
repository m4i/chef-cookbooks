execute 'nginx-quit' do
  action  :nothing
  command "#{node.nginx.source.root}/sbin/nginx -s quit"
end
