unless ::File.exists?(node.macvim.kaoriya.appdir)
  directory node.macvim.kaoriya.appdir do
    mode 0755
  end
end

dmg_package 'MacVim' do
  source      node.macvim.kaoriya.url
  destination node.macvim.kaoriya.appdir
  volumes_dir 'MacVim-KaoriYa'
end

%w( vimrc_local.vim gvimrc_local.vim ).each do |file|
  template "#{node.macvim.kaoriya.appdir}/MacVim.app/Contents/Resources/vim/#{file}" do
    source "kaoriya/#{file}"
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
