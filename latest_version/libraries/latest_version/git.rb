require 'latest_version/base'

module LatestVersion
  class Git < Base
    def initialize(options)
      @url        = options[:url] or raise 'require url'
      @pattern    = to_regexp(options[:pattern] || :stable)
      @to_version = options[:to_version] || -> tag { tag.sub(/\Av/, '') }
    end

    def versions
      tags.map do |tag|
        tag = @to_version.(tag)
        tag if tag =~ /\A#@pattern\z/
      end.compact
    end

    def tags
      ls_remote(@url).scan(%r!\trefs/tags/(.*)$!).flatten
    end

    private

    def ls_remote(url, options = {})
      if git_installed?
        exec_ls_remote(url, options)
      else
        pseudo_ls_remote(url, options)
      end
    end

    def git_installed?
      if @git_installed.nil?
        @git_installed = !!system('which git >/dev/null 2>&1')
      else
        @git_installed
      end
    end

    def exec_ls_remote(url, options)
      @exec_ls_remote_cache ||= {}
      @exec_ls_remote_cache["#{url} #{options.sort.inspect}"] ||= begin
        `git ls-remote #{url}`
      end
    end

    def pseudo_ls_remote(url, options)
      body = http_get("#{url}/info/refs?service=git-upload-pack")

      body.sub!(/\A.*\n0000(.*)\0.*/, '\1')            &&
      body.sub!(/^0000\z/, '')                         &&
      body.gsub!(/^00[\da-f]{2}[\da-f]{40} /, "\\1\t") or
      raise 'invalid response'

      body
    end
  end
end
