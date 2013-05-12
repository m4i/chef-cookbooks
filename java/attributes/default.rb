default.java.oracle.tap do |o|
  o.root     = node[:java] && node[:java][:root] || '/usr/local'
  o.version  = '1.7.0_21'

  url_version = node.java.oracle.version.sub(/^1\./, '').sub(/\.0_/, 'u')
  base_url    = node.java.oracle[:base_url]

  %w(
    jdk        jdk
    jre        jre
    server-jre jdk
  ).each_slice(2) do |key, extracted_dir_name_prefix|
    o[key].root    = node.java.oracle.root
    o[key].version = node.java.oracle.version

    o[key].url =
      if node.kernel.name == 'Linux'
        case node.kernel.machine
        when 'x86_64'; "#{base_url}#{key}-#{url_version}-linux-x64.tar.gz"
        when /^i.86$/; "#{base_url}#{key}-#{url_version}-linux-i586.tar.gz"
        end
      end

    o[key].archive_name = File.basename(node.java.oracle[key].url)

    o[key].extracted_dir_name =
      extracted_dir_name_prefix + node.java.oracle[key].version
  end
end
