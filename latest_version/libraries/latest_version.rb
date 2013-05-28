File.expand_path('..', __FILE__).tap do |path|
  $LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)
end

module LatestVersion
  NAMED_PATTERNS = {
    stable: /\d+(?:\.\d+)*/,
    all:    ::Gem::Version::VERSION_PATTERN,
  }

  autoload :Gem,        'latest_version/gem'
  autoload :Git,        'latest_version/git'
  autoload :GitHub,     'latest_version/github'
  autoload :GoogleCode, 'latest_version/google_code'
  autoload :Html,       'latest_version/html'

  class << self
    def gem(options)
      self::Gem.new(options).latest_version
    end

    def git(options)
      self::Git.new(options).latest_version
    end

    def github(options)
      self::GitHub.new(options).latest_version
    end

    def google_code(options)
      self::GoogleCode.new(options).latest_version
    end

    def html(options)
      self::Html.new(options).latest_version
    end
  end
end
