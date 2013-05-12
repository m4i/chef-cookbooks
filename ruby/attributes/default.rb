default.ruby.tap do |d|
  d.default_recipe = 'ruby-build'
  d.version        = '2.0.0-p0'
end

default.ruby.source.tap do |s|
  s.root    = node[:source] && node[:source][:root] || '/usr/local'
  s.version = node.ruby.version
  s.url     = 'http://ftp.ruby-lang.org/pub/ruby/%s/ruby-%s.tar.bz2' % [
    node.ruby.source.version.split('.').take(2).join('.'),
    node.ruby.source.version,
  ]
end

default.ruby['ruby-build'].tap do |r|
  r.version       = node.ruby.version
  r.prefix        = "/opt/rubies/#{node.ruby['ruby-build'].version}"
  r.system_chruby = false
end
