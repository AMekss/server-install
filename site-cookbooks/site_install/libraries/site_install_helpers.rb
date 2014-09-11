module SiteInstallHelpers
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

  def setup_database(user_name, stage)
    bash 'create db user for app user' do
      user 'postgres'
      code "psql postgres -tAc \"SELECT 1 FROM pg_roles WHERE rolname='#{user_name}'\" | grep -q 1 || createuser -d -e -s -P -w #{user_name}"
    end

    bash 'create db for app user' do
      user "#{user_name}"
      code "psql postgres -tAc \"SELECT 1 FROM pg_database WHERE datname='#{user_name}_#{stage}'\" | grep -q 1 || createdb -E UTF8 -e #{user_name}_#{stage}"
    end
  end
end
