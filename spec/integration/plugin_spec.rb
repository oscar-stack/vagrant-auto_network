require 'spec_helper'

describe AutoNetwork::Plugin do
  include_context 'vagrant-unit'

  context 'when a vagrant environment is initialized' do
    let(:settings) {
      Module.new do
        extend AutoNetwork::Settings
      end
    }
    let(:manager_double) { double().as_null_object }

    it 'sets the global pool_manager' do
      allow(AutoNetwork).to receive(:pool_manager=) do |pool_manager|
        settings.pool_manager = pool_manager
      end
      allow(manager_double).to receive(:new).and_return('a_pool_manager')
      stub_const('AutoNetwork::PoolManager', manager_double)

      # Create an environment \o/
      isolated_environment.create_vagrant_env

      expect(settings.pool_manager).to eq('a_pool_manager')
    end

  end
end
