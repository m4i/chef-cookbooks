unless platform?('ubuntu', 'mac_os_x')
  raise "#{node.platform} is not supported by the #{cookbook_name}::#{recipe_name} recipe"
end

value_for_platform(
  mac_os_x: { default: %w() },
  ubuntu: { default: %w(
    gcc
    g++
    autoconf
    make
  ) }
).each {|pkg| package pkg }
