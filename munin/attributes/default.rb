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
  s.github = 'munin-monitoring/munin'
  unless node.munin.source[:version]
    s.version = LatestVersion.github(
      name:    node.munin.source.github,
      pattern: /\d+\.\d*[02468]\.\d+/,
    )
  end
end
