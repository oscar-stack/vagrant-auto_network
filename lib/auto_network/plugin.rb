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
        auto_middleware = AutoNetwork::Action::Network
        env_middleware  = AutoNetwork::Action::GenPool

        vbox_middleware = VagrantPlugins::ProviderVirtualBox::Action::Network

        hook.before(vbox_middleware, env_middleware)
        hook.before(vbox_middleware, auto_middleware)
      end
    end

    command(:'auto-network') do
      require_relative 'command'
      AutoNetwork::Command
    end
  end
end
