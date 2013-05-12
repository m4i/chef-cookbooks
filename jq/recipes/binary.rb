unless node.jq.binary[:url]
  raise "#{node.platform} is not supported by the #{cookbook_name}::#{recipe_name} recipe"
end

remote_file "#{node.jq.binary.bindir}/jq" do
  action :create_if_missing
  source node.jq.binary.url
  mode   0755
end
