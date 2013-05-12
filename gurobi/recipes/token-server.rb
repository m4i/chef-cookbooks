template "/etc/init/grb_ts.conf" do
  mode 0644

  only_if do
    %W(
      #{node.gurobi.prefix}/linux64/bin/grb_ts
      #{node.gurobi.prefix}/linux64/bin/grbd
    ).any do |daemon|
      if File.exists?(daemon)
        variables daemon: daemon
        true
      end
    end
  end
end
