default.macvim.kaoriya.tap do |d|
  unless node.macvim.kaoriya[:version]
    d.version  = LatestVersion.google_code(name: 'macvim-kaoriya', suffix: '.dmg')
  end
  d.url    = "https://macvim-kaoriya.googlecode.com/files/macvim-kaoriya-#{node.macvim.kaoriya.version}.dmg"
  d.appdir = "#{ENV['HOME']}/Applications"
end
