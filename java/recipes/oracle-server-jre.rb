source 'server-jre' do
  action      node.java.oracle['server-jre'][:action]
  source_keys %w( java oracle server-jre )

  build   false
  install -> {
    # mv /usr/local/src/server-jre/1.7.0_21 /usr/local/app/server-jre/1.7.0_21
    execute "mv #{attr.srcdir} #{attr.prefix}" do
      not_if { installed? }
    end
  }
end
