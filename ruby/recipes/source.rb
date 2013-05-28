include_recipe 'ruby::depends'

source 'ruby' do
  action node.ruby.source[:action]
end

node.default.ruby.prefix = node.ruby.source.prefix

include_recipe 'ruby::install-basic-gems'
