actions :install, :upgrade, :uninstall
default_action node[:source] && node.source[:action] || :install

attribute :root,     kind_of: String,                  default: '/usr/local'
attribute :use_git,  kind_of: [TrueClass, FalseClass], default: false
attribute :use_paco, kind_of: [TrueClass, FalseClass], default: false

attribute :source_keys, kind_of: Array

attribute :build, kind_of: [String, Hash, Proc, FalseClass],
  default: './configure --prefix=%{prefix} %{configure_options} && make'
attribute :install, kind_of: [String, Hash, Proc, FalseClass],
  default: 'make install'

attribute :pre_set_attributes,  kind_of: Proc
attribute :post_set_attributes, kind_of: Proc
attribute :pre_build,           kind_of: Proc
attribute :post_build,          kind_of: Proc
attribute :pre_install,         kind_of: Proc
attribute :post_install,        kind_of: Proc


def after_created
  @run_context.include_recipe('paco') if use_paco?
  set_version_by_git!
  set_attributes!
end

def _source_keys
  source_keys || [name, :source]
end

def attr(base = node)
  _source_keys.inject(base) do |attributes, key|
    attributes[key]
  end
end

def default_attr
  attr(node.default)
end

# priority of version
#
# 1. node.foobar.source.version
# 2. node.foobar.source.git_commit[0, 7]
# 3. node.foobar.source.git_tag
# 4. node.foobar.source.git_branch's commit[0, 7]
def set_version_by_git!
  return unless use_git?

  if attr[:github] && !attr[:git_repository]
    default_attr.git_repository = "https://github.com/#{attr[:github]}.git"
  end

  unless attr[:git_branch]
    default_attr.git_branch = 'master'
  end

  unless attr[:version]
    default_attr.version =
      case
      when attr[:git_commit]
        attr.git_commit[/\A[\da-f]{7}(?=[\da-f]{33}\z)/] || attr.git_commit
      when attr[:git_tag]
        attr.git_tag
      else
        # TODO: independent from git command
        result = `git ls-remote --heads #{attr.git_repository} refs/heads/#{attr.git_branch}`
        unless hash = result[/\A[\da-f]{7}(?=[\da-f]{33}\b)/]
          raise "cannot find #{attr.git_branch} in #{attr.git_repository}"
        end
        hash
      end
  end
end

def set_attributes!
  callback = pre_set_attributes and instance_exec(&callback)

  # foobar
  unless attr[:appname]
    default_attr.appname = name
  end

  # 1.2.3-bazqux
  unless attr[:path_version]
    default_attr.path_version = attr.version
  end

  # foobar-1.2.3-bazqux
  unless attr[:appname_with_version]
    default_attr.appname_with_version =
      "#{attr.appname}-#{attr.path_version}"
  end

  # /usr/local
  unless attr[:root]
    default_attr.root =
      node[:source] && node.source[:root] || root
  end

  # /usr/local/app
  unless attr[:appdir_base]
    default_attr.appdir_base = "#{attr.root}/app"
  end

  # /usr/local/app/foobar
  unless attr[:appdir_parent]
    default_attr.appdir_parent = ::File.join(
      attr.appdir_base,
      attr.appname
    )
  end

  # /usr/local/app/foobar/1.2.3-bazqux
  unless attr[:prefix]
    default_attr.prefix = ::File.join(
      attr.appdir_parent,
      attr.path_version
    )
  end

  # /usr/local/opt
  unless attr[:optdir_base]
    default_attr.optdir_base = "#{attr.root}/opt"
  end

  # /usr/local/opt/nginx
  unless attr[:optdir]
    default_attr.optdir = ::File.join(
      attr.optdir_base,
      attr.appname
    )
  end

  # /usr/local/src
  unless attr[:srcdir_base]
    default_attr.srcdir_base = ::File.join(attr.root, 'src')
  end

  # /usr/local/src/foobar
  unless attr[:srcdir_parent]
    default_attr.srcdir_parent = ::File.join(
      attr.srcdir_base,
      attr.appname
    )
  end

  # /usr/local/src/foobar/1.2.3-bazqux
  unless attr[:srcdir]
    default_attr.srcdir = ::File.join(
      attr.srcdir_parent,
      attr.path_version
    )
  end

  unless use_git?
    if attr[:github] && !attr[:url]
      default_attr.url = 'https://github.com/%s/archive/%s.tar.gz' % [
        attr.github,
        git_reference || attr.version,
      ]
    end

    # 1.2.3.tar.gz
    unless attr[:archive_name]
      default_attr.archive_name = "#{attr.version}#{extname(attr.url)}"
    end

    # /usr/local/src/foobar/1.2.3.tar.gz
    unless attr[:archive_path]
      default_attr.archive_path = ::File.join(
        attr.srcdir_parent,
        attr.archive_name
      )
    end
  end

  callback = post_set_attributes and instance_exec(&callback)
end

def git_reference
  attr[:git_commit] || attr[:git_tag] || attr[:git_branch]
end

def use_git?
  return !!attr.use_git unless attr[:use_git].nil?
  use_git
end

def use_paco?
  return !!attr.use_paco unless attr[:use_paco].nil?
  return !!node.source.use_paco if node[:source] && !node.source[:use_paco].nil?
  use_paco
end

def extname(path)
  path[/\.tar\.[\da-z]+\z/] || ::File.extname(path)
end
