default.java.oracle.tap do |o|
  o.version  = '1.7.0_21'

  url_version = node.java.oracle.version.sub(/^1\./, '').sub(/\.0_/, 'u')
  base_url    = node.java.oracle[:base_url]

  %w( jdk jre server-jre ).each do |key|
    o[key].version = node.java.oracle.version

    o[key].url =
      if node.kernel.name == 'Linux'
        case node.kernel.machine
        when 'x86_64'; "#{base_url}#{key}-#{url_version}-linux-x64.tar.gz"
        when /^i.86$/; "#{base_url}#{key}-#{url_version}-linux-i586.tar.gz"
        end
      end

    o[key].archive_name = File.basename(node.java.oracle[key].url)
  end
end
