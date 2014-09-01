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
end