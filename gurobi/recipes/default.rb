prefix_parent = File.dirname(node.gurobi.prefix)

# mkdir -p /opt
directory prefix_parent do
  mode      0755
  recursive true
end

# mkdir -p /usr/local/src
directory node.gurobi.package_dir do
  mode      0755
  recursive true
end

archive_filename   = File.basename(node.gurobi.url)
extracted_dir_path = "#{node.gurobi.package_dir}/#{node.gurobi.extracted_dir_name}"

# cd /usr/local/src
# curl -LO example.com/gurobi5.5.0_linux64.tar.gz
remote_file "#{node.gurobi.package_dir}/#{archive_filename}" do
  action :create_if_missing
  source node.gurobi.url
  mode   0644
end

# rm -rf gurobi550
directory extracted_dir_path do
  action    :delete
  recursive true
end

# tar xfo gurobi5.5.0_linux64.tar.gz
execute "tar xfo #{archive_filename}" do
  cwd    node.gurobi.package_dir
  not_if { ::File.exists?(node.gurobi.prefix) }
end

# mv gurobi550 /opt
execute "mv #{node.gurobi.extracted_dir_name} #{prefix_parent}" do
  cwd    node.gurobi.package_dir
  not_if { ::File.exists?(node.gurobi.prefix) }
end
