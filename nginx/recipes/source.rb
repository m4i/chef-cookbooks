unless platform?('ubuntu')
  raise "#{node.platform} is not supported by the #{cookbook_name}::#{recipe_name} recipe"
end

include_recipe 'build-essential'

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
    libcurl4-openssl-dev
    libpcre3-dev
    libssl-dev
    zlib1g-dev
  ) }
).each {|pkg| package pkg }

if node.nginx.passenger.enabled
  include_recipe 'ruby'

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

  node.default.nginx.source.configure_options =
    node.nginx.source.configure_options + %W(
      --add-module=#{node.nginx.passenger.prefix}/ext/nginx
    )
end

source 'nginx' do
  action node.nginx.source[:action]

  if node.nginx.passenger.enabled
    pre_set_attributes -> {
      default_attr.path_version = '%s-ruby-%s-passenger-%s' % [
        attr.version,
        node.ruby.version,
        node.nginx.passenger.version,
      ]
    }

    pre_build -> {
      gem_package 'passenger' do
        version    node.nginx.passenger.version
        gem_binary "#{node.ruby.prefix}/bin/gem"
      end
    }
  end
end


include_recipe 'nginx::quit'

node.default.nginx.prefix = node.nginx.source.root

%W(
  #{node.nginx.temp_dir}
  #{node.nginx.conf_dir}/conf.d
  #{node.nginx.conf_dir}/sites
  #{node.nginx.conf_dir}/snippets
).each do |path|
  directory path do
    mode 0755
  end
end

%w(
  nginx.conf.erb
  snippets/assets.conf
  snippets/common.conf
  snippets/favicon.conf
  snippets/no-favicon.conf
).each do |path|
  template "#{node.nginx.conf_dir}/#{path.sub(/\.erb\z/, '')}" do
    source   "conf/#{path}"
    mode     0644
    # reload だと
    #     bind() to 0.0.0.0:80 failed (98: Address already in use)
    # のようなエラーが出るため quit を利用
    #notifies :reload, 'service[nginx]'
    notifies :run, 'execute[nginx-quit]'
  end
end

if node.nginx.default_host
  template "#{node.nginx.conf_dir}/sites/default.conf" do
    source   'conf/sites/default.conf'
    mode     0644
    #notifies :reload, 'service[nginx]'
    notifies :run, 'execute[nginx-quit]'
  end
end

if node.nginx.passenger.enabled
  template "#{node.nginx.conf_dir}/conf.d/passenger.conf" do
    source   'conf/conf.d/passenger.conf.erb'
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
