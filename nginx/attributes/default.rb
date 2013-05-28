default.nginx.tap do |d|
  d.default_recipe = 'source'

  d.user  = 'nginx'
  d.group = 'nginx'
  d.uid   = 980
  d.gid   = 980
  d.home  = '/var/lib/nginx'

  d.conf_dir  = '/etc/nginx'
  d.log_dir   = '/var/log/nginx'
  d.pid_path  = '/var/run/nginx.pid'
  d.lock_path = '/var/lock/nginx.lock'
  d.temp_dir  = '/var/lib/nginx'

  d.default_host = node.fqdn

  d.passenger.enabled = false
  if node.nginx.passenger.enabled && !node.nginx.passenger[:version]
    d.passenger.version = LatestVersion.gem(name: 'passenger')
  end
end

default.nginx.source.tap do |s|
  unless node.nginx.source[:version]
    s.version = LatestVersion.html(
      url:     'http://nginx.org/download/',
      pattern: /\d+\.\d*[02468]\.\d+/,
    )
  end
  s.url = "http://nginx.org/download/nginx-#{node.nginx.source.version}.tar.gz"

  s.configure_options = %W(
    --conf-path=#{node.nginx.conf_dir}/nginx.conf
    --error-log-path=#{node.nginx.log_dir}/error.log
    --pid-path=#{node.nginx.pid_path}
    --lock-path=#{node.nginx.lock_path}

    --user=#{node.nginx.user}
    --group=#{node.nginx.group}

    --http-log-path=#{node.nginx.log_dir}/access.log
    --http-client-body-temp-path=#{node.nginx.temp_dir}/body
    --http-proxy-temp-path=#{node.nginx.temp_dir}/proxy
    --http-fastcgi-temp-path=#{node.nginx.temp_dir}/fastcgi
    --http-uwsgi-temp-path=#{node.nginx.temp_dir}/uwsgi
    --http-scgi-temp-path=#{node.nginx.temp_dir}/scgi

    --with-http_ssl_module
    --with-http_realip_module
    --with-http_gzip_static_module
    --with-http_stub_status_module

    --without-http_ssi_module
    --without-http_userid_module
    --without-http_geo_module
    --without-http_split_clients_module
    --without-http_referer_module
    --without-http_uwsgi_module
    --without-http_scgi_module
    --without-http_memcached_module
    --without-http_limit_conn_module
    --without-http_limit_req_module
    --without-http_browser_module
  )
end

default.nginx.conf.tap do |c|
  c.worker_processes   = node.cpu.total
  c.worker_connections = 1024
end
