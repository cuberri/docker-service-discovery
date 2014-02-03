# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "coreos"
  config.vm.box_url = "http://storage.core-os.net/coreos/amd64-generic/dev-channel/coreos_production_vagrant.box"

  config.vm.host_name = "logstash-workspace"

  # etcd (mainly exposed in order to access dashboard on http://localhost:4001/mod/dashboard)
  # config.vm.network "forwarded_port", guest: 4001, host: 4001

  # nginx
  config.vm.network "forwarded_port", guest: 80, host: 80
end
