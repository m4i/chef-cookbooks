define :source, action: :install do
  name = params[:name]

  source = -> key = nil, base = node do
    source_keys = Array(params[:source_keys] || [name, :source])
    attributes = source_keys.inject(base) do |attributes, key|
      attributes[key]
    end
    key ? attributes[key] : attributes
  end

  default_source  = source.(nil, node.default)
  override_source = source.(nil, node.override)

  # priority of version
  #
  # 1. node.foobar.source.git.version
  # 2. git branch commit hash
  # 3. node.foobar.source.git.reference
  if source[:git]
    if source[:git][:branch]
      default_source.git.reference = source[:git].branch
    end

    unless source[:git][:version]
      default_source.git.version =
        if source[:git][:branch]
          result = `git ls-remote #{source[:git].url} #{source[:git].branch}`
          unless hash = result[/\A[\da-f]{7}/]
            raise "cannot find #{source[:git].branch} in #{source[:git].url}"
          end
          hash
        elsif source[:git].reference =~ /\A[\da-f]{40}\z/
          source[:git].reference[0, 7]
        else
          source[:git].reference
        end
    end

    override_source.version = source[:git].version
  end

  # foobar
  unless source[:app_name]
    default_source.app_name = name
  end
  # foobar-1.2.3
  unless source[:app_name_with_version]
    default_source.app_name_with_version =
      "#{source[:app_name]}-#{source[:version]}"
  end
  # /usr/local/app
  unless source[:app_base_dir_path]
    default_source.app_base_dir_path = "#{source[:root]}/app"
  end
  # /usr/local/app/foobar/1.2.3
  unless source[:prefix]
    default_source.prefix = File.join(
      source[:app_base_dir_path],
      source[:app_name],
      source[:version]
    )
  end
  # /usr/local/opt
  unless source[:opt_base_dir_path]
    default_source.opt_base_dir_path = "#{source[:root]}/opt"
  end
  # /usr/local/opt/nginx
  unless source[:opt_dir_path]
    default_source.opt_dir_path = File.join(
      source[:opt_base_dir_path],
      source[:app_name]
    )
  end
  # /usr/local/src
  unless source[:src_base_dir_path]
    default_source.src_base_dir_path = "#{source[:root]}/src"
  end
  # /usr/local/src/foobar-1.2.3
  unless source[:src_dir_path]
    default_source.src_dir_path = File.join(
      source[:src_base_dir_path],
      source[:app_name_with_version]
    )
  end
  unless source[:git]
    # foobar-1.2.3.tar.gz
    unless source[:archive_name]
      # foobar.tar.gz
      url_filename = ::File.basename(source[:url])
      # .tar.gz
      archive_extname =
        url_filename[/\.tar\.[\da-z]+$/] || ::File.extname(url_filename)
      # foobar-1.2.3.tar.gz
      default_source.archive_name =
        "#{source[:app_name_with_version]}#{archive_extname}"
    end
  end


  case params[:action]
  when :install
    include_recipe 'paco'

    # mkdir /usr/local/src
    directory source[:src_base_dir_path] do
      mode 0755
    end

    # rm -rf /usr/local/src/foobar-1.2.3
    directory source[:src_dir_path] do
      action    :delete
      recursive true
      not_if    { ::File.exists?(source[:prefix]) }
    end

    if source[:git]
      # cd /usr/local/src
      # git clone http://example.com/foobar.git /usr/local/src/foobar-1.2.3
      # cd foobar
      # foobar checkout v1.2.3
      git source[:src_dir_path] do
        action     :checkout
        repository source[:git].url
        reference  source[:git].reference
      end
    else
      # cd /usr/local/src
      # curl -O http://example.com/foobar-1.2.3.tar.gz
      remote_file "#{source[:src_base_dir_path]}/#{source[:archive_name]}" do
        action :create_if_missing
        source source[:url]
        mode   0644
      end

      if source[:extracted_dir_name]
        # rm -rf foobar-123
        directory "#{source[:src_base_dir_path]}/#{source[:extracted_dir_name]}" do
          action    :delete
          recursive true
        end
      end

      # tar xfo foobar-1.2.3.tar.gz
      execute "tar xfo #{source[:archive_name]}" do
        cwd    source[:src_base_dir_path]
        not_if { ::File.exists?(source[:prefix]) }
      end

      if source[:extracted_dir_name]
        # mv foobar-123 foobar-1.2.3
        execute "mv #{source[:extracted_dir_name]} #{source[:app_name_with_version]}" do
          cwd    source[:src_base_dir_path]
          not_if { ::File.exists?(source[:prefix]) }
        end
      end
    end

    if params[:pre_build]
      instance_exec(source, &params[:pre_build])
    end

    unless params[:install_command] == false
      # ./configure
      # make
      # paco -p foobar-1.2.3 make install
      bash "build-and-install-#{source[:app_name]}" do
        cwd source[:src_dir_path]

        if params[:install_command]
          install_command = params[:install_command]
        else
          build_command = params[:build_command] || <<-EOC
            ./configure --prefix=%{prefix} %{configure_options}
            make
          EOC
          install_command = <<-EOC
            #{build_command}
            paco -p %{app_name_with_version} make install
          EOC
        end

        hash = Hash[
          source.call.merge(
            configure_options: Array(source[:configure_options]).join(' ')
          ).map {|key, value| [key.to_sym, value] }
        ]

        code <<-EOC
          set -e
          #{install_command % hash}
        EOC
        not_if { ::File.exists?(source[:prefix]) }
      end
    end

    # mkdir /usr/local/opt
    directory source[:opt_base_dir_path] do
      mode 0755
    end

    # ln -s ../app/foobar-1.2.3 /usr/local/opt/foobar
    link source[:opt_dir_path] do
      to "../app/#{source[:app_name]}/#{source[:version]}"
    end

    if params[:pre_create_symlinks]
      instance_exec(source, &params[:pre_create_symlinks])
    end

    # ln -sf ../app/foo/bin/* /usr/local/bin
    ruby_block 'create-symlinks' do
      block do
        {
          'bin/*'  => -> path { path.file? && path.executable? },
          'sbin/*' => -> path { path.file? && path.executable? },
          'man/*/*'                  => -> path { path.file?      },
          "share/#{source[:app_name]}" => -> path { path.directory? },
          'share/man/*/*'            => -> path { path.file?      },
        }.merge(source[:symlinks] || {}).each do |glob, criterion|
          # /usr/local/app/foobar/share/man/man1/foobar.1
          Pathname.glob("#{source[:prefix]}/#{glob}") do |target_path|
            next unless criterion == true || criterion === target_path

            # man/man1/foobar.1
            relative_path = target_path.relative_path_from(Pathname(source[:prefix]))
            # /usr/local/man/man1/foobar.1
            symlink_path = Pathname(source[:root]) + relative_path
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
                symlink_path.delete
              end
            elsif symlink_path.exist?
              symlink_path.rmtree
            end
            symlink_path.make_symlink(link_to)
          end
        end
      end
    end

  when :uninstall
    # rm -rf /usr/local/app/foobar/1.2.3
    directory source[:prefix] do
      action    :delete
      recursive true
    end

  else
    raise "unknown action: #{params[:action]}"
  end
end
