if node.munin.master
  include_recipe 'nginx'
end


group node.munin.group do
  gid node.munin.gid
end

user node.munin.user do
  uid   node.munin.uid
  gid   node.munin.gid
  home  node.munin.home
  shell '/bin/false'
end


# https://github.com/munin-monitoring/munin/blob/master/INSTALL
value_for_platform(
  ubuntu: { default: %w(
    make
    libcrypt-des-perl
    libdigest-hmac-perl
    libnet-server-perl
    libnet-snmp-perl
    libnet-ssleay-perl
  ) }
).each {|pkg| package pkg }

if node.munin.master
  value_for_platform(
    ubuntu: { default: %w(
      libcgi-fast-perl
      libdate-manip-perl
      libfile-copy-recursive-perl
      libhtml-template-perl
      liblog-log4perl-perl
      libparams-validate-perl
      librrds-perl
      liburi-perl
      spawn-fcgi
    ) }
  ).each {|pkg| package pkg }
end


source 'munin' do
  action node.munin.source[:action]

  build 'make'

  unless node.munin.master
    install <<-EOC
      make \
        install-common-prime \
        install-node-prime \
        install-plugins-prime
    EOC
  end

  pre_build -> {
    file File.join(attr.srcdir, 'Makefile.config') do
      only_if do
        content File.read(path).tap {|content|
          content.sub!(/^(PREFIX\s*=).*/)    { "#$1 #{attr.prefix}" }
          content.sub!(/^(CONFDIR\s*=).*/)   { "#$1 #{node.munin.confdir}" }
          content.sub!(/^(DBDIR\s*=).*/)     { "#$1 #{node.munin.dbdir}" }
          content.sub!(/^(DBDIRNODE\s*=).*/) { "#$1 #{node.munin.dbdirnode}" }
          content.sub!(/^(LOGDIR\s*=).*/)    { "#$1 #{node.munin.logdir}"  }
          content.sub!(/^(STATEDIR\s*=).*/)  { "#$1 #{node.munin.rundir}"  }
        }
      end
    end
  }
end


node.default.munin.prefix  = node.munin.source.root
node.default.munin.htmldir = "#{node.munin.source.optdir}/www/docs"
node.default.munin.cgidir  = "#{node.munin.source.optdir}/www/cgi"

include_recipe 'munin::node-setup'
include_recipe 'munin::master-setup' if node.munin.master
