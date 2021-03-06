# encoding: utf-8
#
# Cookbook Name:: ssh-hardening
# Recipe:: ssh_server.rb
#
# Copyright 2012, Dominik Richter
# Copyright 2014, Deutsche Telekom AG
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

package 'openssh-server' do
  package_name node['sshserver']['package']
end

directory '/etc/ssh' do
  mode 0755
  owner 'root'
  group 'root'
  action :create
end

template '/etc/ssh/sshd_config' do
  source 'opensshd.conf.erb'
  mode 0600
  owner 'root'
  group 'root'
  variables(
    mac: SshMac.get_macs(node, node['ssh']['weak_hmac']),
    kex: SshKex.get_kexs(node, node['ssh']['weak_kex']),
    cipher: SshCipher.get_ciphers(node, node['ssh']['cbc_required'])
  )
end

keys = []
Chef::Log.info 'ssh_server: not setting up any ssh keys' if keys.empty?

directory '/root/.ssh' do
  mode 0500
  owner 'root'
  group 'root'
  action :create
end

template '/root/.ssh/authorized_keys' do
  source 'authorized_keys.erb'
  mode 0400
  owner 'root'
  group 'root'
  variables(
    keys: keys
  )
  only_if { !keys.empty? }
end

execute 'unlock root account if it is locked' do
  command "sed 's/^root:\!/root:*/' /etc/shadow -i"
  only_if { node['ssh']['allow_root_with_key'] }
end
