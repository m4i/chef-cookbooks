unless platform?('ubuntu')
  raise "#{node.platform} is not supported by the #{cookbook_name}::#{recipe_name} recipe"
end

include_recipe 'build-essential'

value_for_platform(
  ubuntu: { default: %w(
    gettext
    libcurl4-openssl-dev
    libexpat-dev
    libpcre3-dev
    zlib1g-dev
  ) }
  # centos
  # curl-devel
  # expat-devel
  # openssl-devel
  # pcre-devel
).each {|pkg| package pkg }

source 'git' do
  action node.git.source[:action]

  post_install -> {
    man_archive_name = File.basename(attr.man_url)
    man_path         = "#{attr.prefix}/share/man"

    remote_file File.join(attr.srcdir_parent, man_archive_name) do
      action :create_if_missing
      source attr.man_url
      mode   0644
    end

    execute "tar xfo #{man_archive_name} -C #{man_path}" do
      cwd    attr.srcdir_parent
      not_if { ::File.exists?("#{man_path}/man1/git.1") }
    end
  }
end
