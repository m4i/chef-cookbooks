require 'find'

def whyrun_supported?
  true
end


action :install do
  install unless installed_any_version?
end

action :upgrade do
  install
end

action :uninstall do
  uninstall
end


def install
  create_base_directories

  create_srcdir_parent
  if @new_resource.use_git?
    git_clone_source
  else
    download_archive
    extract_archive
  end

  build
  _install

  create_opt_symlink
  create_symlinks
  delete_symlinks(current: false, other: true)
end

def uninstall
  _uninstall
  delete_symlinks(current: true)
end

def create_base_directories
  # mkdir /usr/local/app
  directory attr.appdir_base { mode 0755 }

  # mkdir /usr/local/opt
  directory attr.optdir_base { mode 0755 }

  # mkdir /usr/local/src
  directory attr.srcdir_base { mode 0755 }
end

def create_srcdir_parent
  # mkdir /usr/local/src/foobar
  directory attr.srcdir_parent do
    mode 0755
  end
end

def download_archive
  # curl http://example.com/foobar-latest.tar.gz \
  #   -o /usr/local/src/foobar/1.2.3.tar.gz
  remote_file attr.archive_path do
    action :create_if_missing
    source attr.url
    mode   0644
  end
end

def extract_archive
  _delete_srcdir

  # mkdir /tmp/chef-source-xxx
  # tar xfo /usr/local/src/foobar/1.2.3.tar.gz -C /tmp/chef-source-xxx
  # mv /tmp/chef-source-xxx/foobar-1.2.3 /usr/local/src/foobar/1.2.3-bazqux
  # rmdir /tmp/chef-source-xxx
  ruby_block "tar xfo #{attr.archive_path}" do
    block do
      tmpdir do |tmpdir|
        tmpdir = Pathname(tmpdir)
        system *%W( tar xfo #{attr.archive_path} -C #{tmpdir} )
        case tmpdir.children.length
        when 0; raise "cannot extract #{attr.archive_path}"
        when 1; tmpdir.children.first.rename(attr.srcdir)
        else    tmpdir.rename(attr.srcdir)
        end
      end
    end
    not_if { installed? }
  end
end

def git_clone_source
  _delete_srcdir

  git_reference = @new_resource.git_reference

  # git clone http://example.com/foobar.git /usr/local/src/foobar/1.2.3-bazqux
  # cd /usr/local/src/foobar/1.2.3-bazqux
  # git checkout v1.2.3
  git attr.srcdir do
    action     :checkout
    repository attr.git_repository
    reference  git_reference
  end
end

def _delete_srcdir
  # rm -rf /usr/local/src/foobar/1.2.3-bazqux
  directory attr.srcdir do
    action    :delete
    recursive true
    not_if    { installed? }
  end
end

def build
  return if (build = @new_resource.build) == false

  callback = @new_resource.pre_build and instance_exec(&callback)

  case build
  when String, Hash
    command, environment = extract_execute_options(build)

    # cd /usr/local/src/foobar/1.2.3-bazqux
    # ./configure
    # make
    execute command % attr_hash do
      cwd         attr.srcdir
      environment environment
      not_if      { installed? }
    end

  when Proc
    instance_exec(&build)
  end

  callback = @new_resource.post_build and instance_exec(&callback)
end

def _install
  return if (install = @new_resource.install) == false

  callback = @new_resource.pre_install and instance_exec(&callback)

  # mkdir /usr/local/app/foobar
  directory attr.appdir_parent do
    mode 0755
  end

  case install
  when String, Hash
    command, environment = extract_execute_options(install)

    if @new_resource.use_paco? && command !~ /\A\s*paco\s/
      command = "paco --package=%{appname_with_version} #{command}"
    end

    # cd /usr/local/src/foobar/1.2.3-bazqux
    # paco --package=foobar-1.2.3-bazqux make install
    execute command % attr_hash do
      cwd         attr.srcdir
      environment environment
      not_if      { installed? }
    end

  when Proc
    instance_exec(&install)
  end

  callback = @new_resource.post_install and instance_exec(&callback)
end

def extract_execute_options(options)
  if options.is_a?(Hash)
    command     = options[:command]
    environment = options[:environment].
      each_with_object({}) do |(key, value), env|
        env[key] = value % attr_hash
      end
  else
    command     = options
    environment = nil
  end

  [command, environment]
end

def _uninstall
  if @new_resource.use_paco?
    # paco --remove --batch foobar-1.2.3-bazqux
    execute "paco --remove --batch #{attr.appname_with_version}" do
      only_if { system("paco #{attr.appname_with_version} >/dev/null") }
    end
  end

  # rm -rf /usr/local/app/foobar/1.2.3-bazqux
  directory attr.prefix do
    action    :delete
    recursive true
  end

  # rmdir /usr/local/app/foobar
  directory attr.appdir_parent do
    action  :delete
    only_if do
      path = Pathname(attr.appdir_parent)
      path.exist? && path.children.empty?
    end
  end
end

def create_opt_symlink
  # ln -s ../app/foobar/1.2.3-bazqux /usr/local/opt/foobar
  link attr.optdir do
    to Pathname(attr.prefix).
       relative_path_from(Pathname(attr.optdir_base)).to_s
  end
end

def create_symlinks
  # ln -sf ../app/foo/bin/* /usr/local/bin
  ruby_block "create #{attr.appname} symlinks" do
    block do
      {
        'bin/*'  => -> path { path.file? && path.executable? },
        'sbin/*' => -> path { path.file? && path.executable? },
        'man/*/*'               => -> path { path.file?      },
        "share/#{attr.appname}" => -> path { path.directory? },
        'share/man/*/*'         => -> path { path.file?      },
      }.merge(attr[:symlinks] || {}).each do |glob, criterion|
        # /usr/local/app/foobar/share/man/man1/foobar.1
        Pathname.glob("#{attr.prefix}/#{glob}") do |target_path|
          next unless criterion == true || criterion === target_path

          # man/man1/foobar.1
          relative_path = target_path.relative_path_from(Pathname(attr.prefix))
          # /usr/local/man/man1/foobar.1
          symlink_path = Pathname(attr.root) + relative_path
          # /usr/local/man/man1
          symlink_dir_path = symlink_path.parent
          # mkdir -p /usr/local/man/man1
          symlink_dir_path.mkpath unless symlink_dir_path.exist?
          # /usr/local/man/man1 -> /usr/local/share/man/man1
          symlink_dir_path = symlink_dir_path.realpath
          # /usr/local/man/man1/foobar.1 -> /usr/local/share/man/man1/foobar.1
          symlink_path = symlink_dir_path + symlink_path.basename
          # ../../../app/foobar/share/man/man1/foobar.1
          link_to = target_path.relative_path_from(symlink_dir_path)

          if symlink_path.symlink?
            if symlink_path.readlink == link_to
              break
            else
              converge_by("delete symlink at #{symlink_path} to #{symlink_path.readlink}") do
                symlink_path.delete
              end
            end
          elsif symlink_path.exist?
            converge_by("delete file/directory at #{symlink_path}") do
              symlink_path.rmtree
            end
          end
          converge_by("create symlink at #{symlink_path} to #{link_to}") do
            symlink_path.make_symlink(link_to)
          end
        end
      end
    end
  end
end

def delete_symlinks(target)
  case target.keys
  when [:all]
    only  = :all
    force = target[:all]
  when [:current]
    only  = :current
    force = target[:current]
  end

  # rm /usr/local/bin/foobar
  ruby_block "delete #{attr.appname} symlinks" do
    block do
      appdir_parent_regex = %r!\A#{Regexp.escape(attr.appdir_parent)}(?:/|\z)!
      prefix_regex        = %r!\A#{Regexp.escape(attr.prefix)}(?:/|\z)!

      Find.find(attr.root).each do |path|
        # skip /usr/local/app/** and /usr/local/src/**
        if [attr.appdir_base, attr.srcdir_base].include?(path)
          Find.prune
          next
        end

        next unless ::File.symlink?(path)

        symlink_path = Pathname(path)
        link_to      = symlink_path.parent + symlink_path.readlink

        case only
        when :all
          next unless link_to.to_s =~ appdir_parent_regex
        when :current
          next unless link_to.to_s =~ prefix_regex
        else
          next unless link_to.to_s =~ appdir_parent_regex
          force = (
            link_to.to_s =~ prefix_regex ? target[:current] : target[:other]
          ) || target[:all]
          next if force.nil?
        end

        if force || !link_to.exist?
          converge_by("delete symlink at #{symlink_path} to #{link_to}") do
            symlink_path.delete
          end
        end
      end
    end
  end
end


def installed?
  ::File.exists?(attr.prefix)
end

def installed_any_version?
  ::File.realpath(attr.optdir)
  true
rescue Errno::ENOENT
  false
end

def attr
  @new_resource.attr
end

def attr_hash
  Hash[
    attr.merge(
      configure_options: Array(attr[:configure_options]).join(' ')
    ).map {|key, value| [key.to_sym, value] }
  ]
end

def tmpdir(&block)
  require 'tempfile'
  tempfile = Tempfile.new('chef-source')
  path = tempfile.path
  tempfile.close!

  begin
    Dir.mkdir(path)
    yield path
  ensure
    Dir.rmdir(path) if ::File.exists?(path)
  end
end
