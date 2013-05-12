unless platform?('ubuntu')
  raise "#{node.platform} is not supported by the #{cookbook_name}::#{recipe_name} recipe"
end

include_recipe 'build-essential'

value_for_platform(
  ubuntu: { default: %w(
    liblzma-dev
    libpcre3-dev
    pkg-config
    zlib1g-dev
  ) }
).each {|pkg| package pkg }

source 'the_silver_searcher' do
  action        :install
  build_command './build.sh --prefix=%{prefix}'
end
