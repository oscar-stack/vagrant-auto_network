require 'vagrant'
require 'auto_network/action'

module AutoNetwork
  class Plugin < Vagrant.plugin('2')
    name 'auto_network'

    description <<-DESC
    This plugin adds support for automatically configuring Vagrant hostonly
    networks.
    DESC

    action_hook('Auto network: initialize address pool') do |hook|
      hook.prepend AutoNetwork::Action::LoadPool
    end

    action_hook('Auto network: filter private networks', :environment_load) do |hook|
      action = AutoNetwork::Action::LoadPool
      hook.after(action, AutoNetwork::Action::FilterNetworks)
    end

    action_hook('Auto network: request address', :machine_action_up) do |hook|
      action = VagrantPlugins::ProviderVirtualBox::Action::Network
      hook.before(action, AutoNetwork::Action::Request)
    end

    action_hook('Auto network: release address', :machine_action_destroy) do |hook|
      action = VagrantPlugins::ProviderVirtualBox::Action::Destroy
      hook.before(action, AutoNetwork::Action::Release)
    end
  end
end
