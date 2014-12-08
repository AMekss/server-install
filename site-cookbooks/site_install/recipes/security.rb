::Chef::Recipe.send(:include, SiteInstallHelpers)

# Users & groups
bash 'create sysadmin group' do
  user 'root'
  code 'groupadd -f sysadmin'
end

create_site_user node[:root_user], true

setup_firewall
