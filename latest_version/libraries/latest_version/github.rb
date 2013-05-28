require 'latest_version/git'

module LatestVersion
  class GitHub < Git
    def initialize(options)
      raise 'require name' unless options[:name]

      super({
        url: "https://github.com/#{options[:name]}.git",
      }.merge(options))
    end
  end
end
