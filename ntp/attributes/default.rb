default.ntp.tap do |d|
  d.service_name =
    case platform
    when 'ubuntu'; 'ntp'
    when 'redhat'; 'ntpd'
    end

  d.servers = %w(
    ntp.nict.jp
    ntp.jst.mfeed.ad.jp
  )

  d.current_time_url = 'http://ntp-a1.nict.go.jp/cgi-bin/json'
  #d.current_time_url = 'http://ntp-b1.nict.go.jp/cgi-bin/json'
end
