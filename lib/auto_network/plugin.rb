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
      stack.use AutoNetwork::Action::Network
      hook.prepend stack
    end

    action_hook('Auto network: filter private networks') do |hook|
      action = AutoNetwork::Action::GenPool
      hook.after(action, AutoNetwork::Action::Network)
    end

    action_hook('Auto network: release address', 'machine_action_destroy'.to_sym) do |hook|
      action = AutoNetwork::Action::Network
      hook.after(action, AutoNetwork::Action::Release)
    end
  end
end
