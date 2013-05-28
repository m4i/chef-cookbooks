require 'latest_version/base'
require 'rss'

module LatestVersion
  class Gem < Base
    def initialize(options)
      @name    = options[:name] or raise 'require name'
      @pattern = to_regexp(options[:pattern] || :stable)
    end

    def versions
      gem_feed.entries.map do |entry|
        version = entry.title.content[/(?<=\()(.*)(?=\)$)/]
        version if version =~ /\A#@pattern\z/
      end.compact.uniq
    end

    def gem_feed
      atom = http_get("https://rubygems.org/gems/#@name/versions.atom")
      RSS::Parser.parse(atom, false)
    end
  end
end
