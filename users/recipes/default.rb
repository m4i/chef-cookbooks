default_user = {
  'shell'    => '/bin/bash',
  'supports' => { manage_home: true }
}

pubkeys = data_bag('users').include?('pubkeys') ?
  data_bag_item('users', 'pubkeys')['pubkeys'] : {}

node.users.groups.each do |group|
  data_bag_item('users', group)['users'].each do |user|
    user = default_user.merge('home' => "/home/#{user['name']}").merge(user)

    if %w( false nologin ).include?(File.basename(user['shell']))
      user['supports'] = nil
    end

    # useradd --uid 2000 --gid 2000 --groups adm,sudo \
    #         --home /home/foobar --create-home --shell /bin/bash foobar
    user user['name'] do
      action :create
      %w( uid gid groups password home shell supports ).each do |key|
        send(key, user[key]) if user[key]
      end
    end

    if pubkeys[user['name']]
      # mkdir -m 0700 ~/.ssh
      directory "#{user['home']}/.ssh" do
        owner user['name']
        group user['gid'] || user['name']
        mode  0700
      end

      # cat {pubkeys} > ~/.ssh/authorized_keys
      # chmod 0600 ~/.ssh/authorized_keys
      file "#{user['home']}/.ssh/authorized_keys" do
        action  :create_if_missing
        content pubkeys[user['name']].join("\n") + "\n"
        owner   user['name']
        group   user['gid'] || user['name']
        mode    0600
      end
    end
  end
end
