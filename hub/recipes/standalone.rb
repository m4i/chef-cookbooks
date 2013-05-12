remote_file "#{node.hub.standalone.bindir}/hub" do
  action :create_if_missing
  source node.hub.standalone.url
  mode   0755
end
