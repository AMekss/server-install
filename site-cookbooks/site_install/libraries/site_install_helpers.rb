module SiteInstallHelpers
  def install_ruby(rb_version)
    rbenv_ruby rb_version do
      global true
    end

    rbenv_gem 'bundler' do
      ruby_version rb_version
    end
  end

  def create_site_user(user, sudoer=false)
    user user[:name] do
      password user[:password]
      home "/home/#{user[:name]}"
      supports manage_home: true
      shell '/bin/bash'
    end

    directory "/home/#{user[:name]}/.ssh" do
      owner user[:name]
      group user[:name]
      mode 0700
      action :create
    end

    file "/home/#{user[:name]}/.ssh/authorized_keys" do
      owner user[:name]
      group user[:name]
      content Array(user[:authorized_keys]).join("\n")
      mode 0644
      action :create
    end

    bash "add to sudoers" do
      user 'root'
      code "usermod -a -G sysadmin #{user[:name]}"
    end if sudoer
  end

  def setup_firewall
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
  end

  def setup_database(user_name, stage)
    bash 'create db user for app user' do
      user 'postgres'
      code "psql postgres -tAc \"SELECT 1 FROM pg_roles WHERE rolname='#{user_name}'\" | grep -q 1 || createuser -d -e -s -w #{user_name}"
    end

    bash 'create db for app user' do
      user "#{user_name}"
      code "psql postgres -tAc \"SELECT 1 FROM pg_database WHERE datname='#{user_name}_#{stage}'\" | grep -q 1 || createdb -E UTF8 -e #{user_name}_#{stage}"
    end
  end

  def setup_nginx(site_name, nginx_user, site_group)
    bash 'clean nginx defaults' do
      user 'root'
      code 'rm /etc/nginx/sites-enabled/*'
    end

    template "/etc/nginx/sites-available/#{site_name}" do
      owner 'root'
      group 'root'
      source 'nginx.conf.erb'
      action :create
    end

    bash 'symlink site config' do
      user 'root'
      code "ln -nfs /etc/nginx/sites-available/#{site_name} /etc/nginx/sites-enabled/#{site_name}"
    end

    bash 'add rights' do
      user 'root'
      code "usermod -a -G #{site_group} #{nginx_user}"
    end

    service 'nginx' do
      action :restart
    end
  end

  def setup_unicorn(site_name)
    template "/etc/init.d/unicorn_#{site_name}" do
      owner 'root'
      group 'root'
      source 'unicorn_init.sh.erb'
      mode 0755
      action :create
    end

    bash 'start unicorn on server restart' do
      user 'root'
      code "update-rc.d -f unicorn_#{site_name} defaults"
    end
  end

  def setup_logrotate(name, path)
    template "/etc/logrotate.d/#{name}" do
      owner 'root'
      group 'root'
      helper(:log_path) { path }
      source 'logrotate.conf.erb'
      mode 0644
      action :create
    end
  end

end
