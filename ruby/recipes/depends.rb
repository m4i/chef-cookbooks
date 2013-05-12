unless platform?('ubuntu', 'mac_os_x')
  raise "#{node.platform} is not supported by the #{cookbook_name}::#{recipe_name} recipe"
end

include_recipe 'build-essential'

value_for_platform(
  mac_os_x: { default: %w(
    readline
  ) },
  ubuntu: { default: %w(
    libreadline-dev
    libssl-dev
    zlib1g-dev
  ) }
  # centos
  # readline-devel
  # openssl-devel
  # zlib-devel
).each {|pkg| package pkg }
