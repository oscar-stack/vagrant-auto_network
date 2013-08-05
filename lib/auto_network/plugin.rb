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
        before     = VagrantPlugins::ProviderVirtualBox::Action::Network
        middleware = AutoNetwork::Action::Network

        hook.before(before, middleware)
      end
    end
  end
end
