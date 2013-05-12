interval = 3600

case node.platform
when 'ubuntu'
  execute 'apt-get update' do
    not_if do
      path = '/var/lib/apt/periodic/update-success-stamp'
      ::File.exists?(path) && ::File.mtime(path) > Time.now - interval
    end
  end

when 'mac_os_x'
  execute 'brew update' do
    not_if do
      path = '/usr/local/.git'
      ::File.exists?(path) && ::File.mtime(path) > Time.now - interval
    end
  end

else
  raise "#{node.platform} is not supported by the #{cookbook_name}::#{recipe_name} recipe"
end
