require 'spec_helper'
require_relative 'shared/auto_network_1x_context'

describe AutoNetwork::Plugin do
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
    it 'releases the allocated IP address' do
      env = test_env.create_vagrant_env
      test_machine = env.machine(:test1, :dummy)

      expect(current_ip(test_machine)).to eq('10.20.1.2')

      test_machine.action(:destroy)

      expect(current_ip(test_machine)).to be_nil
    end
  end

  describe 'when running the request action' do
    subject {
      Vagrant::Action::Builder.new.tap {|b| b.use AutoNetwork::Action::Request }
    }

    context 'on a machine with no IP allocated' do
      it 'allocates an IP address' do
        env = test_env.create_vagrant_env
        test_machine = env.machine(:test2, :dummy)

        expect(current_ip(test_machine)).to be_nil

        # This emulates Machine#action_raw which didn't show up until
        # Vagrant 1.6.0
        action_env = { :machine => test_machine }
        env.action_runner.run(subject, action_env)

        expect(current_ip(test_machine)).to eq('10.20.1.3')
      end
    end

    context 'on a machine with an allocated IP address' do
      it 'assigns the address to unfiltered network interfaces' do
        env = test_env.create_vagrant_env
        test_machine = env.machine(:test3, :dummy)

        action_env = { :machine => test_machine }
        env.action_runner.run(subject, action_env)

        _, network_opts = test_machine.config.vm.networks.find {|n| n.first == :private_network}
        expect(network_opts).to include(:ip => '10.20.1.4')
      end
    end
  end
end
