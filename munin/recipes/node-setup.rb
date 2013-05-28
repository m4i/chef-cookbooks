%W(
  #{node.munin.confdir}/munin-node.conf conf/munin-node.conf.erb
  /etc/init/munin-node.conf             upstart/munin-node.conf.erb
  /etc/logrotate.d/munin-node           logrotate/munin-node.erb
).each_slice(2) do |path, source|
  template path do
    mode   0644
    source source
  end
end

execute 'munin-node-configure --shell | sed "s/^ln -s/&f/" | sh -x' do
  not_if   { `munin-node-configure --shell`.strip.empty? }
  notifies :restart, 'service[munin-node]'
end

service 'munin-node' do
  action   [:enable, :start]
  provider Chef::Provider::Service::Upstart
end
