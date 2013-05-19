attributes = node.vim['macvim-kaoriya']

unless ::File.exists?(attributes.app_dir)
  directory attributes.app_dir
end

dmg_package 'MacVim' do
  source      attributes.url
  destination attributes.app_dir
  checksum    attributes.checksum
  volumes_dir 'MacVim-KaoriYa'
end

%w( vimrc_local.vim gvimrc_local.vim ).each do |file|
  template "#{attributes.app_dir}/MacVim.app/Contents/Resources/vim/#{file}" do
    source "macvim-kaoriya/#{file}"
    mode   0644
  end
end

# https://code.google.com/p/macvim-kaoriya/wiki/Readme
execute 'defaults write org.vim.MacVim MMZoomBoth -boolean YES' do
  not_if { system('defaults read org.vim.MacVim MMZoomBoth >/dev/null 2>&1') }
end
execute 'defaults write org.vim.MacVim MMNativeFullScreen 0' do
  not_if { system('defaults read org.vim.MacVim MMNativeFullScreen >/dev/null 2>&1') }
end
