unless platform?('ubuntu')
  raise "#{node.platform} is not supported by the #{cookbook_name}::#{recipe_name} recipe"
end

include_recipe 'build-essential'
include_recipe 'nginx::quit'

group node.nginx.group do
  gid node.nginx.gid
end

user node.nginx.user do
  uid   node.nginx.uid
  gid   node.nginx.gid
  home  node.nginx.home
  shell '/bin/false'
end

value_for_platform(
  ubuntu: { default: %w(
    libpcre3-dev
    libssl-dev
    zlib1g-dev
  ) }
).each {|pkg| package pkg }

source 'nginx' do
  action :install

  if node.nginx.passenger.enable
    pre_build -> source {
      include_recipe 'ruby'

      gem_package 'passenger' do
        version    node.nginx.passenger.version
        gem_binary "#{node.ruby.prefix}/bin/gem"
      end

      node.default.nginx.passenger.prefix =
        '%s/lib/ruby/gems/%s/gems/passenger-%s' % [
          node.ruby.prefix,
          # TODO: 動的に取得したい
          case
          when node.ruby.version.start_with?('1.8.'); '1.8'
          when node.ruby.version.start_with?('1.9.'); '1.9.1'
          else node.ruby.version.split('-').first
          end,
          node.nginx.passenger.version
        ]

      source[:configure_options].concat %W(
        --with-cc-opt=-Wno-error
        --add-module=#{node.nginx.passenger.prefix}/ext/nginx
      )
    }
  end
end


node.default.nginx.prefix = node.nginx.source.root

[node.nginx.temp_dir, '/etc/nginx/conf.d', '/etc/nginx/sites'].each do |path|
  directory path do
    mode 0755
  end
end

%w(
  /etc/nginx/nginx.conf         conf/nginx.conf.erb
  /etc/nginx/server-common.conf conf/server-common.conf
).each_slice(2) do |path, source|
  template path do
    source   source
    mode     0644
    # reload だと
    #     bind() to 0.0.0.0:80 failed (98: Address already in use)
    # のようなエラーが出るため quit を利用
    #notifies :reload, 'service[nginx]'
    notifies :run, 'execute[nginx-quit]'
  end
end

if node.nginx.default_host
  template '/etc/nginx/sites/default.conf' do
    source   'conf/default.conf'
    mode     0644
    #notifies :reload, 'service[nginx]'
    notifies :run, 'execute[nginx-quit]'
  end
end

if node.nginx.passenger.enable
  template '/etc/nginx/conf.d/passenger.conf' do
    source   'conf/passenger.conf.erb'
    mode     0644
    #notifies :reload, 'service[nginx]'
    notifies :run, 'execute[nginx-quit]'
  end
end

%w(
  /etc/init/nginx.conf   upstart/nginx.conf.erb
  /etc/logrotate.d/nginx logrotate/nginx.erb
).each_slice(2) do |path, source|
  template path do
    source source
    mode   0644
  end
end

service 'nginx' do
  action   :start
  supports restart: true, reload: true, status: true
  provider Chef::Provider::Service::Upstart
end
