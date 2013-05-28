require 'latest_version/base'

module LatestVersion
  class Html < Base
    DEFAULT_PREFIX       = /\b/
    DEFAULT_SUFFIX       = '.tar.gz'
    DEFAULT_FILE_PATTERN = /<a[^>]* href=["']([^"']*)["']/

    def initialize(options)
      @url          = options[:url] or raise 'require url'
      @pattern      = to_regexp(options[:pattern] || :stable)
      @prefix       = to_regexp(options[:prefix]       || DEFAULT_PREFIX)
      @suffix       = to_regexp(options[:suffix]       || DEFAULT_SUFFIX)
      @file_pattern = to_regexp(options[:file_pattern] || DEFAULT_FILE_PATTERN)
    end

    def versions
      files.map do |archive|
        $1 if archive =~ /#@prefix(#@pattern)#@suffix\z/
      end.compact.uniq
    end

    def files
      html.scan(@file_pattern).flatten.uniq
    end

    def html
      http_get(@url)
    end
  end
end
