default.jq.tap do |d|
  d.binary.bindir = '/usr/local/bin'
  d.binary.url =
    if node.kernel.name == 'Linux'
      case node.kernel.machine
      when 'x86_64'; 'http://stedolan.github.io/jq/download/linux64/jq'
      when /^i.86$/; 'http://stedolan.github.io/jq/download/linux32/jq'
      end
    end
end
