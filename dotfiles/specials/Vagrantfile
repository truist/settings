# symlink this file into ~/.vagrant.d/

$script = <<SCRIPT
export DEBIAN_FRONTEND=noninteractive
apt-get -y install git-core > /dev/null
SCRIPT

Vagrant::Config.run do |config|
	config.vm.provision "shell", inline: $script
	config.vm.share_folder "userenv", "/home/vagrant/src/settings", File.expand_path("~/src/settings")
end
