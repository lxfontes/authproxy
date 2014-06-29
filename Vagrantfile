VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "phusion-open-ubuntu-12.04-amd64"
  config.vm.box_url = "https://oss-binaries.phusionpassenger.com/vagrant/boxes/ubuntu-12.04.3-amd64-vbox.box"
  config.ssh.forward_agent = true
  config.vm.provision :shell, path: 'vagrantup.sh'
  config.vm.network "public_network"


  config.vm.define "web1" do |web|
  end

  config.vm.define "web2" do |web|
  end

end
