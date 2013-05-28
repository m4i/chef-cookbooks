%w( bundler jruby-openssl ).each do |gem|
  gem_package gem do
    gem_binary "env -i #{node.jruby.prefix}/bin/jruby -S gem"
  end
end
