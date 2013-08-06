require 'vagrant'
require 'auto_network/action'

module AutoNetwork
  class Plugin < Vagrant.plugin('2')
    name 'auto_network'

    description <<-DESC
    This plugin adds support for automatically configuring Vagrant hostonly
    networks.
    DESC

    %w[up reload].each do |action_type|
      action = "machine_action_#{action_type}".to_sym
      action_hook(:auto_network, action) do |hook|

        stack = Vagrant::Action::Builder.new
        stack.use AutoNetwork::Action::GenPool
        stack.use AutoNetwork::Action::Network

        vbox = VagrantPlugins::ProviderVirtualBox::Action::Network

        hook.before(vbox, stack)
      end
    end

    action_hook(:auto_network, 'machine_action_destroy'.to_sym) do |hook|
      vbox = VagrantPlugins::ProviderVirtualBox::Action::Destroy

      stack = Vagrant::Action::Builder.new
      stack.use AutoNetwork::Action::GenPool
      stack.use AutoNetwork::Action::Release

      hook.before(vbox, stack)
    end
  end
end
