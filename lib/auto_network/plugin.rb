require 'vagrant'
require 'auto_network/action'

module AutoNetwork
  class Plugin < Vagrant.plugin('2')
    name 'auto_network'

    description <<-DESC
    This plugin adds support for automatically configuring Vagrant hostonly
    networks.
    DESC

    action_hook('Auto network: load address pool') do |hook|
      stack = Vagrant::Action::Builder.new
      stack.use AutoNetwork::Action::GenPool
      stack.use AutoNetwork::Action::FilterNetworks
      hook.prepend stack
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
