%w( bundler ).each do |gem|
  gem_package gem do
    gem_binary "env -i #{node.ruby.prefix}/bin/gem"
  end
end
