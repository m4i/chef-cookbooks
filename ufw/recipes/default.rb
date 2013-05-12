return unless node[:ufw]

firewall 'ufw' do
  action :enable
end

apply_rule = -> rules do
  case
  when rules.respond_to?(:each_value)
    p rules
    if rules[:name]
      rule = rules
      firewall_rule rule.name do
        action rule[:action] ? rule.action : 'allow'

        interface rule.interface if rule[:interface]
        direction rule.direction if rule[:direction]

        protocol rule.protocol.to_sym if rule[:protocol]

        port  rule.port  if rule[:port]
        ports rule.ports if rule[:ports]
        if rule[:ports_range]
          ports_range rule.ports_range.first .. rule.ports_range.last
        end

        source      rule.source      if rule[:source]
        destination rule.destination if rule[:destination]
        dest_port   rule.dest_port   if rule[:dest_port]

        position rule.position if rule[:position]
      end

    else
      rules.each_value do |rule|
        apply_rule.(rule)
      end
    end
  when rules.respond_to?(:each)
    rules.each do |rule|
      apply_rule.(rule)
    end
  else
    raise "invalid rules: #{rules.inspect}"
  end
end

apply_rule.(node.ufw)
