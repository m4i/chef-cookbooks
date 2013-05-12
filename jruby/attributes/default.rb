default.jruby.tap do |d|
  d.version = '1.7.3'
end

default.jruby.binary.tap do |b|
  b.version     = node.jruby.version
  b.prefix      = "/opt/rubies/jruby-#{node.jruby.binary.version}"
  b.package_dir = '/usr/local/src'
  b.url         = "http://jruby.org.s3.amazonaws.com/downloads/#{node.jruby.binary.version}/jruby-bin-#{node.jruby.binary.version}.tar.gz"
end

default.jruby['ruby-build'].tap do |r|
  r.version = "jruby-#{node.jruby.version}"
  r.prefix  = "/opt/rubies/#{node.jruby['ruby-build'].version}"
end
