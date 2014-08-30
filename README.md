# Server installation scripts with Chef-solo/Knife-solo/Berkshelf

## Description

* Chef-solo is for installation cookbooks
* Knife-solo is for cookbooks deployment to server
* Berkshelf is for cookbooks dependency management

## Installation
````
$ bundle install
````

## Usage
Add server specification into nodes/{host}.json

**Note** for security reasons all real node specs are kept into separate private repo. Node specification example:

````json
{
  "run_list": [
    "recipe[sudo]",
    "recipe[rbenv::default]",
    "recipe[rbenv::ruby_build]",
    "recipe[nodejs::nodejs_from_binary]",
    "recipe[nginx::source]",
    "recipe[redisio::install]",
    "recipe[redisio::enable]",
    "recipe[postgresql::server]",
    "recipe[postgresql::config_initdb]",
    "recipe[postgresql::config_pgtune]",
    "recipe[site_install]",
    "recipe[diptables]",
    "recipe[ssh-hardening]",
    "recipe[os-hardening]"
  ],
  "user": {
    "name": "app user name",
    "password": "shadowed password for app user",
    "authorized_keys": [
      "list of public keys to be added during site install"
    ]
  },
  "postgresql": {
    "password": {
      "postgres": "shadowed password for db"
    },
    "config_pgtune": {
      "db_type": "web"
    }
  },
  "automatic": {
    "ipaddress": "192.168.33.10"
  }
}

````
and then run commands below to install the server
````
$ ./bin/init {user}@{host}
$ knife solo cook {user}@{host}
````
Check chef supermarket for more details on any cookbook used in this project and setup available.

## Resources
* Cookbook supermarket https://supermarket.getchef.com/
* Chef resources http://docs.getchef.com/chef/resources.html
* Knife-solo setup demo https://github.com/sajnikanth/knife-solo-demo
* Berkshelf setup demo https://github.com/sajnikanth/berkshelf-demo

## Disclaimer
Instalation scripts are tested against Ubuntu servers, but might work with other distros too.
