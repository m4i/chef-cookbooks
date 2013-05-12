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
  action :install

  pre_create_symlinks -> source {
    man_archive_name = File.basename(source[:man].url)
    man_path         = "#{source[:prefix]}/share/man"

    remote_file "#{source[:src_base_dir_path]}/#{man_archive_name}" do
      action :create_if_missing
      source source[:man].url
      mode   0644
    end

    execute "tar xfo #{man_archive_name} -C #{man_path}" do
      cwd    source[:src_base_dir_path]
      not_if { ::File.exists?("#{man_path}/man1/git.1") }
    end
  }
end
