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
  action node.tig.source[:action]

  # build に必要な package が多いためデフォルトでインストールしない
  # https://github.com/jonas/tig/blob/master/INSTALL
  if node.tig.source.install_doc
    post_install -> {
      command = 'make install-doc'
      if @new_resource.use_paco?
        command = "paco -p tig-doc-#{attr.path_version} #{command} "
      end

      execute command do
        cwd    attr.srcdir
        not_if { ::File.exists?(File.join(attr.prefix, 'share/man')) }
      end
    }
  end
end
