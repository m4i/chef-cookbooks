package 'ntp'
package 'ntpdate'

service 'ntp' do
  action       [:enable, :start]
  service_name node.ntp.service_name
  supports     status: true, restart: true
end

file '/etc/ntp.conf' do
  only_if do
    original_content = File.read(path)
    content = original_content.dup

    content.gsub!(/^(?=server (.*))/) do
      '#' unless node.ntp.servers.include?($1)
    end

    content.rstrip!
    content << "\n"

    servers = ''
    node.ntp.servers.each do |server|
      unless content =~ /^server #{server}$/
        servers << "server #{server}\n"
      end
    end
    unless servers.empty?
      content << "\n" << servers
    end

    content(content) if content != original_content
  end

  notifies :restart, 'service[ntp]'
end
