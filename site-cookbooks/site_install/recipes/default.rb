require 'securerandom'
::Chef::Recipe.send(:include, SiteInstallHelpers)

install_ruby '2.1.2'

create_site_user node[:app_user]

directory "/home/#{node[:app_user][:name]}/#{node[:stage]}" do
  owner node[:app_user][:name]
  group node[:app_user][:name]
  action :create
end

template "/home/#{node[:app_user][:name]}/#{node[:stage]}/.rbenv-vars" do
  owner node[:app_user][:name]
  group node[:app_user][:name]
  source 'rbenv-vars.erb'
  mode 0700
  action :create_if_missing
end

setup_database node[:app_user][:name], node[:stage]
setup_nginx "#{node[:app_user][:name]}_#{node[:stage]}", node[:nginx][:user], node[:app_user][:name]
setup_unicorn "#{node[:app_user][:name]}_#{node[:stage]}"

setup_logrotate "#{node[:app_user][:name]}_#{node[:stage]}_application", "/home/#{node[:app_user][:name]}/#{node[:stage]}/shared/log/*.log"
setup_logrotate "#{node[:app_user][:name]}_#{node[:stage]}_nginx", "/var/log/nginx/*.log"
