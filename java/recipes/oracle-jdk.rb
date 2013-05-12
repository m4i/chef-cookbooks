source 'jdk' do
  action          :install
  source_keys     %w( java oracle jdk )
  install_command false

  pre_build -> source {
    directory File.dirname(source[:prefix]) do
      mode 0755
    end

    execute "mv #{source[:app_name_with_version]} #{source[:prefix]}" do
      cwd    source[:src_base_dir_path]
      not_if { ::File.exists?(source[:prefix]) }
    end
  }
end
