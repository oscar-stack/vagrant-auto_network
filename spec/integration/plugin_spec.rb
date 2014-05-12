require 'spec_helper'
require_relative 'shared/auto_network_1x_context'

describe AutoNetwork::Plugin do
  include_context 'vagrant-unit'
  include_context 'auto_network 1.x'

  context 'when a vagrant environment is initialized' do
    it 'sets the global pool_manager' do
      # Create an environment \o/
      test_env.create_vagrant_env

      expect(settings.pool_manager).to be_a(AutoNetwork::PoolManager)
    end

    it 'assigns autonetworked IP addresses to existing machines' do
      env = test_env.create_vagrant_env

      test_machine = env.machine(:test1, :dummy)
      _, network_opts = test_machine.config.vm.networks.find {|n| n.first == :private_network}

      expect(network_opts).to include(:ip => '10.20.1.2')
    end
  end

  context 'when destroying a machine' do
    def current_ip(machine)
      settings.pool_manager.with_pool_for(machine) {|p| p.address_for(machine)}
    end

    it 'releases the allocated IP address' do
      env = test_env.create_vagrant_env
      test_machine = env.machine(:test1, :dummy)

      expect(current_ip(test_machine)).to eq('10.20.1.2')

      test_machine.action(:destroy)

      expect(current_ip(test_machine)).to be_nil
    end
  end

  # Testing IP allocation is pretty tricky since it hooks into
  # provider-specific behavior that our dummy provider does not have.
  # Currently, this behavior is exercised by the acceptance tests.
  context 'when creating a machine' do
    it 'allocates an IP address' do
      pending 'This is currently delegated to the acceptance suite.'
    end
  end
end
