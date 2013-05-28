if node[:git] && node.git[:use_ppa] && platform?('ubuntu')
  apt_repository 'git' do
    uri          'http://ppa.launchpad.net/git-core/ppa/ubuntu/'
    distribution node.lsb.codename
    components   %w( main )
    deb_src      true
    keyserver    'keyserver.ubuntu.com'
    key          'E1DF1F24'
  end
end

package 'git'
