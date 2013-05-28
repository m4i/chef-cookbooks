source 'jdk' do
  action      node.java.oracle.jdk[:action]
  source_keys %w( java oracle jdk )

  build   false
  install -> {
    # mv /usr/local/src/jdk/1.7.0_21 /usr/local/app/jdk/1.7.0_21
    execute "mv #{attr.srcdir} #{attr.prefix}" do
      not_if { installed? }
    end
  }
end
