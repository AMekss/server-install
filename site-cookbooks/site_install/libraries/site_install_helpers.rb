module SiteInstallHelpers
  def create_site_user(user_name, user_pass, sudoer=false)
    user user_name do
      password user_pass
      home "/home/#{user_name}"
      supports manage_home: true
      shell '/bin/bash'
    end

    directory "/home/#{user_name}/.ssh" do
      owner user_name
      group user_name
      mode 0700
      action :create
    end

    file "/home/#{user_name}/.ssh/authorized_keys" do
      owner user_name
      group user_name
      content Array(node[:user][:authorized_keys]).join("\n")
      mode 0644
      action :create
    end

    bash "add to sudoers" do
      user 'root'
      code "usermod -a -G sysadmin #{user_name}"
    end if sudoer
  end
end