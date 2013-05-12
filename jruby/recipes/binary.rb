prefix_parent = File.dirname(node.jruby.binary.prefix)

directory prefix_parent do
  mode      0755
  recursive true
end

directory node.jruby.binary.package_dir do
  mode      0755
  recursive true
end

archive_filename = File.basename(node.jruby.binary.url)

remote_file "#{node.jruby.binary.package_dir}/#{archive_filename}" do
  action :create_if_missing
  source node.jruby.binary.url
  mode   0644
end

execute "tar xfo #{archive_filename} -C #{prefix_parent}" do
  cwd    node.jruby.binary.package_dir
  not_if { ::File.exists?(node.jruby.binary.prefix) }
end

link "#{node.jruby.binary.prefix}/bin/ruby" do
  to 'jruby'
end

%w( bundler jruby-openssl ).each do |gem|
  execute "#{node.jruby.binary.prefix}/bin/jruby --1.9 -S gem install #{gem}" do
    only_if do
      Dir["#{node.jruby.binary.prefix}/lib/ruby/gems/*/gems/#{gem}-*"].empty?
    end
  end
end
