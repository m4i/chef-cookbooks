case node.platform
when 'mac_os_x'
  execute 'ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"' do
    not_if   { File.exist?('/usr/local/bin/brew') }
    notifies :run, 'execute[brew update]'
  end

  execute 'brew update' do
    action :nothing
  end

else
  raise "#{node.platform} is not supported by the #{cookbook_name}::#{recipe_name} recipe"
end
