# Encoding: UTF-8

include_recipe 'parallels'

parallels_app 'default' do
  action :remove
end
