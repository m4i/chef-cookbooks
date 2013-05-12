default_params = {
  ntp_restart: true,
  ntpd_path:   '/usr/sbin/ntpd',
  difference:  nil,
}

define :ntpdate, default_params do
  if params[:difference]
    current_time   = Time.now
    time_json_path = "#{Chef::Config[:file_cache_path]}/ntp-current-time.json"

    remote_file time_json_path do
      source params[:current_time_url]
    end

    is_wrong_time = -> do
      time_json = JSON.parse(File.read(time_json_path))
      (current_time - Time.at(time_json['st'])).abs > params[:difference]
    end

    execute "ntpdate -u #{params[:name]}" do
      only_if &is_wrong_time
    end

    if params[:ntp_restart]
      service 'ntp-restart' do
        action       :restart
        supports     restart: true
        service_name node.ntp.service_name
        only_if      { is_wrong_time.call && File.exists?(params[:ntpd_path]) }
      end
    end

    file time_json_path do
      action :delete
    end

  else
    execute "ntpdate -u #{params[:name]}"

    if params[:ntp_restart]
      service 'ntp-restart' do
        action       :restart
        supports     restart: true
        service_name node.ntp.service_name
        only_if      { File.exists?(params[:ntpd_path]) }
      end
    end
  end
end
