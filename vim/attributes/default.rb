default.vim['macvim-kaoriya'].tap do |m|
  m.version  = '20121213'
  m.url      = "https://macvim-kaoriya.googlecode.com/files/macvim-kaoriya-#{node.vim['macvim-kaoriya'].version}.dmg"
  m.checksum = '8f5f66c328890dec0e36bf8b2cfb9d8aab095dae'
  m.app_dir  = "#{ENV['HOME']}/Applications"
end
