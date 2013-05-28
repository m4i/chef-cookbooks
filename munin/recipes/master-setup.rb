%W(
  #{node.munin.confdir}/munin.conf conf/munin.conf.erb
  /etc/cron.d/munin-cron           cron/munin-cron.erb
  /etc/logrotate.d/munin           logrotate/munin.erb
).each_slice(2) do |path, source|
  template path do
    mode   0644
    source source
  end
end

directory "#{node.munin.dbdir}/cgi-tmp" do
  mode      0755
  user      node.nginx.user
  recursive true
end


host = node.munin[:www_host] || 'default'

if node.munin[:www_host]
  template "#{node.nginx.conf_dir}/sites/#{host}.conf" do
    mode     0644
    source   'nginx/server.conf.erb'
    notifies :run, 'execute[nginx-quit]'
  end
end

directory "#{node.nginx.conf_dir}/sites/#{host}" do
  mode 0755
end

template "#{node.nginx.conf_dir}/sites/#{host}/munin.conf" do
  mode       0644
  source    'nginx/location.conf.erb'
  variables path: node.munin[:www_host] ? '' : '/munin'
  notifies  :run, 'execute[nginx-quit]'
end


%w( graph html ).each do |type|
  template "/etc/init/munin-fcgi-#{type}.conf" do
    mode   0644
    source "upstart/munin-fcgi-#{type}.conf.erb"
  end

  service "munin-fcgi-#{type}" do
    action   [:enable, :start]
    provider Chef::Provider::Service::Upstart
  end
end
