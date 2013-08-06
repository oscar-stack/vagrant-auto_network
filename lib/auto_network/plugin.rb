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

    action_hook(:auto_network, 'machine_action_destroy'.to_sym) do |hook|
      vbox_middleware = VagrantPlugins::ProviderVirtualBox::Action::Destroy

      env_middleware     = AutoNetwork::Action::GenPool
      release_middleware = AutoNetwork::Action::Release

      hook.before(vbox_middleware, env_middleware)
      hook.before(vbox_middleware, release_middleware)
    end
  end
end
