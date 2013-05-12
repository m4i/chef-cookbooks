include_recipe 'build-essential'

installed = -> { ::File.exists?('/usr/bin/vmware-uninstall-tools.pl') }

# rm -rf /tmp/{VM,vm}ware*
execute 'rm -rf VMware* vmware-*' do
  cwd    '/tmp'
  not_if &installed
end

# mount /dev/cdrom /mnt
mount '/mnt' do
  device '/dev/cdrom'
  not_if &installed
end

# cd /tmp
# tar xfo /mnt/VMwareTools-*.tar.gz
execute "tar xfo /mnt/VMwareTools-*.tar.gz" do
  cwd    '/tmp'
  not_if &installed
end

# cd /tmp/vmware-tools-distrib
# ./vmware-install.pl
execute './vmware-install.pl --default' do
  cwd      "/tmp/vmware-tools-distrib"
  not_if   &installed
  notifies :run, 'execute[delete-vmware-temporary-files]'
end

# rm -rf /tmp/{VM,vm}ware*
execute 'delete-vmware-temporary-files' do
  action  :nothing
  command 'rm -rf VMware* vmware-*'
  cwd     '/tmp'
end
