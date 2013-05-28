include_recipe 'ruby-build'
include_recipe 'ruby::depends'

ruby_build = node.ruby['ruby-build']

# TODO: Mac OSX 対応
# RUBY_CONFIGURE_OPTS="--with-openssl-dir=`brew --prefix openssl`" rbenv install 2.0.0-p0
execute "ruby-build #{ruby_build.version} #{ruby_build.prefix}" do
  not_if { ::File.exists?(ruby_build.prefix) }
end

chruby_use_path = '/etc/profile.d/chruby_use.sh'
if ruby_build.system_chruby
  template chruby_use_path do
    mode 0644
  end
else
  file chruby_use_path do
    action :delete
  end
end

node.default.ruby.prefix = ruby_build.prefix

include_recipe 'ruby::install-basic-gems'
