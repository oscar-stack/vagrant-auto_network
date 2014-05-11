require 'spec_helper'

describe AutoNetwork::Plugin do
  include_context 'vagrant-unit'

  # Stub the settings attached to the AutoNetwork module so we don't change
  # global state during tests.
  let(:settings) {
    Module.new do
      extend AutoNetwork::Settings
    end
  }

  before(:each) do
    allow(AutoNetwork).to receive(:pool_manager=) do |pool_manager|
      settings.pool_manager = pool_manager
    end
    allow(AutoNetwork).to receive(:pool_manager).and_return { settings.pool_manager }
  end

  # Configure each testing environment to contain an AutoNetwork pool file and
  # a single existing machine that has been allocated in the pool
  let(:test_env) { isolated_environment }
  before(:each) do
    pool_dir = test_env.homedir.join('auto_network')
    pool_dir.mkpath
    pool_dir.join('pool.yaml').open('w+') do |f|
      f.write <<-EOF
---
poolfile_version: 2
pools:
  dummy: !ruby/object:AutoNetwork::Pool
    network_range: 10.20.1.0/29
    pool:
      10.20.1.2:
        path: #{test_env.workdir}
        name: test1
      10.20.1.3: 
      10.20.1.4: 
      10.20.1.5: 
      10.20.1.6: 
EOF
    end

    test_env.vagrantfile <<-EOF
Vagrant.configure("2") do |config|
  config.vm.define 'test1' do |node|
    node.vm.network :private_network, :auto_network => true
  end
end
EOF

    # Touch an ID file so that Vagrant thinks test1 exists. The 'dummy'
    # component of the path actually tells Vagrant which provider is managing
    # the machine. vagrant-spec defines a dummy provider for us.
    machine_dir = test_env.workdir.join('.vagrant/machines/test1/dummy')
    machine_dir.mkpath
    machine_dir.join('id').open('w+') { |f| f.write('') }
  end

  # Dispose of the temporary directory used to run the test.
  after(:each) do
    test_env.close
  end


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
