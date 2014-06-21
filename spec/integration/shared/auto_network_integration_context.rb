# This context leverages the vagrant-spec library to set up isolated Vagrant
# Environments in which integration tests can be run. Some additions are made
# to the stop unit testing environment:
#
#   - The global AutoNetwork::Settings instance is stubbed such that a new
#     settings instance is created for each test.
#
#   - An AutoNetwork pool file is added to each environment.
#
#   - A Vagrantfile and collection of machines are added that use AutoNetwork.
#
# This context can not be used directly. Instead, include one of the
# version-specific contexts:
#
#   - auto_network 1.x
#   - auto_network 0.x
shared_context 'auto_network integration' do
  include_context 'vagrant-unit'

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

  # Configure each testing environment to include an AutoNetwork pool file and
  # some machine definitions.
  let(:test_env) { isolated_environment }
  let(:pool_file) { test_env.homedir.join('auto_network', 'pool.yaml') }
  before(:each) do
    pool_file.dirname.mkpath
    # The actual contents of the poolfile are defined in the version-specific
    # contexts.
    pool_file.open('w+') {|f| f.write pool_file_content}

    # Three machines are defined:
    #
    #   - test1 has an IP allocated in the pool and an ID allocated in the
    #     `.vagrant` directory.
    #
    #   - test2 has no IP or ID allocated.
    #
    #   - test3 has an allocated IP, but no ID.
    test_env.vagrantfile <<-EOF
Vagrant.configure("2") do |config|
  # Normal vanilla node.
  config.vm.define 'plain'

  # Test nodes with AutoNetwork enabled.
  %w[test1 test2 test3].each do |machine|
    config.vm.define machine do |node|
      node.vm.network :private_network, :auto_network => true
    end
  end
end
EOF

    # Touch an ID file so that Vagrant thinks test1 exists. The 'dummy'
    # component of the path actually tells Vagrant which provider is managing
    # the machine. vagrant-spec defines a dummy provider for us.
    machine_dir = test_env.workdir.join('.vagrant/machines/test1/dummy')
    machine_dir.mkpath
    machine_dir.join('id').open('w+') { |f| f.write('some-uuid-string') }
  end

  # Dispose of the temporary Vagrant Environment used to run the test.
  after(:each) do
    test_env.close
  end

  # A helper for grabbing the IP allocated to a machine.
  #
  # TODO: This should probably be in a general utility module under the
  # AutoNetwork namespace.
  def current_ip(machine)
    settings.pool_manager.with_pool_for(machine) {|p| p.address_for(machine)}
  end
end
