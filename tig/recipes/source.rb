unless platform?('ubuntu')
  raise "#{node.platform} is not supported by the #{cookbook_name}::#{recipe_name} recipe"
end

include_recipe 'build-essential'

value_for_platform(
  ubuntu: { default: %w(
    libncursesw5-dev
  ) }
  # centos
  # ncurses-devel
).each {|pkg| package pkg }

source 'tig' do
  action :install

  # build に必要な package が多いためデフォルトでインストールしない
  # https://github.com/jonas/tig/blob/master/INSTALL
  if node.tig.source.install_doc
    pre_create_symlinks -> source {
      execute "paco -p tig-doc-#{source[:version]} make install-doc" do
        cwd    source[:src_dir_path]
        not_if { ::File.exists?("#{source[:prefix]}/share/man") }
      end
    }
  end
end
