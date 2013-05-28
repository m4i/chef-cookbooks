require 'latest_version/html'

module LatestVersion
  class GoogleCode < Html
    def initialize(options)
      raise 'require name' unless options[:name]

      super({
        url:          "https://code.google.com/p/#{options[:name]}/downloads/list",
        file_pattern: %r/<a[^>]* href="detail\?name=([^"&]*)&/,
      }.merge(options))
    end
  end
end
