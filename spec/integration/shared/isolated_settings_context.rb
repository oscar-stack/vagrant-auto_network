shared_context 'auto_network-settings' do
  # Create a Dummy settings module for each test.
  let(:settings) {
    Module.new do
      extend AutoNetwork::Settings
    end
  }

  # Stub the settings attached to the AutoNetwork module so we don't change
  # global state during tests.
  before(:each) do
    allow(AutoNetwork).to receive(:pool_manager=) do |pool_manager|
      settings.pool_manager = pool_manager
    end
    allow(AutoNetwork).to receive(:pool_manager).and_return { settings.pool_manager }
  end
end
