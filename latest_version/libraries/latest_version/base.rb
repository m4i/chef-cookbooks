module LatestVersion
  class Base
    class << self
      def latest_version(versions)
        raise 'versions is empty' if versions.empty?

        versions.map do |version|
          [
            ::Gem::Version.new(version.gsub(/[^\.\dA-Za-z]+/, '.')),
            version,
          ]
        end.sort.last.last
      end
    end

    def latest_version
      self.class.latest_version(versions)
    end

    private

    def http_get(url)
      @http_get_cache ||= {}
      @http_get_cache[url] ||= begin
        require 'open-uri'
        open(url, &:read)
      end
    end

    def to_regexp(pattern)
      case pattern
      when String
        Regexp.escape(pattern)
      when Regexp
        pattern
      when Symbol
        NAMED_PATTERNS[pattern] or
          raise "invalid named pattern: #{pattern.inspect}"
      else
        raise "invalid pattern: #{pattern.inspect}"
      end
    end
  end
end
