default.gurobi.tap do |d|
  d.version            = '5.5.0'
  d.package_dir        = '/usr/local/src'
  d.url                = "#{node.gurobi.base_url}gurobi#{node.gurobi.version}_linux64.tar.gz"
  d.extracted_dir_name = "gurobi#{node.gurobi.version.delete('.')}"
  d.prefix             = "/opt/#{node.gurobi.extracted_dir_name}"
end
