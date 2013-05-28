apt_repository 'newrelic' do
  uri          'http://apt.newrelic.com/debian/'
  distribution 'newrelic'
  components   %w( non-free )
  deb_src      false
  keyserver    'subkeys.pgp.net'
  key          '548C16BF'
end

package 'newrelic-sysmond'


if node[:newrelic] && node.newrelic[:license_id]
  license_key = Chef::EncryptedDataBagItem.load(
    'newrelic-licenses', node.newrelic.license_id)[:license_key]

  unless license_key =~ /\A[\da-f]{40}\z/
    raise "invalid newrelic license_key: #{license_key.inspect}"
  end

  execute "nrsysmond-config --set license_key=#{license_key}" do
    not_if do
      File.read('/etc/newrelic/nrsysmond.cfg') =~ /\b#{license_key}\b/
    end
  end
end


service 'newrelic-sysmond' do
  action   [:enable, :start]
  supports restart: true, status: true
end
