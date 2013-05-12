default.munin.tap do |d|
  d.user  = 'munin'
  d.group = 'munin'
  d.uid   = 949
  d.gid   = 949
  d.home  = '/var/lib/munin'

  d.confdir   = '/etc/munin'
  d.dbdir     = d.home
  d.dbdirnode = '/var/lib/munin-node'
  d.logdir    = '/var/log/munin'
  d.rundir    = '/var/run/munin'

  d.master            = true
  d.monitor_localhost = true
end

default.munin.source.tap do |s|
  s.root    = node[:source] && node[:source][:root] || '/usr/local'
  s.version = '2.0.13'
  s.url     = "http://download.sourceforge.net/project/munin/stable/#{node.munin.source.version}/munin-#{node.munin.source.version}.tar.gz"
end
