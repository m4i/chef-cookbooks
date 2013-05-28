unless platform?('ubuntu')
  raise "#{node.platform} is not supported by the #{cookbook_name}::#{recipe_name} recipe"
end

file '/etc/ssh/sshd_config' do
  only_if do
    content File.read(path).tap {|content|
      if node[:openssh] && node.openssh[:port]
        content.sub!(/^#?(Port) .*/, "\\1 #{node.openssh.port}")
      end
      content.sub!(/^#?(PermitRootLogin) .*/,        '\1 no')
      content.sub!(/^#?(PasswordAuthentication) .*/, '\1 no')
    }
  end

  notifies :restart, 'service[ssh]'
end

service 'ssh' do
  action :nothing
end
