base_url = 'http://ftp.ruby-lang.org/pub/ruby/'

default.ruby.tap do |d|
  d.default_recipe = 'ruby-build'

  unless node.ruby[:version]
    d.version = LatestVersion.html(
      url:     base_url,
      pattern: /\d+(?:\.\d){2}-p\d+/,
    )
  end
end

default.ruby.source.tap do |s|
  s.version = node.ruby.version
  s.url     = '%s%s/ruby-%s.tar.bz2' % [
    base_url,
    node.ruby.source.version.split('.').take(2).join('.'),
    node.ruby.source.version,
  ]
end

default.ruby['ruby-build'].tap do |r|
  r.version       = node.ruby.version
  r.prefix        = "/opt/rubies/#{node.ruby['ruby-build'].version}"
  r.system_chruby = false
end
