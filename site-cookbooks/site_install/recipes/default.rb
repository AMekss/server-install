::Chef::Recipe.send(:include, SiteInstallHelpers)

# Ruby
rb_version = '2.1.2'
rbenv_ruby rb_version do
  global true
end

rbenv_gem 'bundler' do
  ruby_version rb_version
end
# Users & groups
bash 'create sysadmin group' do
  user 'root'
  code 'groupadd -f sysadmin'
end

create_site_user node[:root_user], true
create_site_user node[:user]

# Allow SSH
diptables_rule 'ssh' do
  rule '--proto tcp --dport 22'
end

# Allow HTTP, HTTPS
diptables_rule 'http' do
  rule [ '--proto tcp --dport 80',
         '--proto tcp --dport 443' ]
end

# Allow established sessions to receive traffic
diptables_rule 'turn-back traffic' do
  rule '-m conntrack --ctstate ESTABLISHED,RELATED'
end

# Reject packets other than those explicitly allowed
diptables_policy 'drop_by_default' do
  policy 'DROP'
end