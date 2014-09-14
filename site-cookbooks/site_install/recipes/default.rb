require 'securerandom'
::Chef::Recipe.send(:include, SiteInstallHelpers)

install_ruby '2.1.2'

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

# Users & groups
bash 'create sysadmin group' do
  user 'root'
  code 'groupadd -f sysadmin'
end

create_site_user node[:root_user], true
create_site_user node[:app_user]

setup_firewall

setup_database node[:app_user][:name], node[:stage]
setup_nginx "#{node[:app_user][:name]}_#{node[:stage]}"
setup_unicorn "#{node[:app_user][:name]}_#{node[:stage]}"
