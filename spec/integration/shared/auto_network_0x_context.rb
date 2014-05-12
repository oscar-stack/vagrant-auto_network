require_relative 'isolated_settings_context'

# Creates an environment for each test containing data that would have been
# created by an installation of AutoNetwork 0.x.
shared_context 'auto_network 0.x' do
  include_context 'vagrant-unit'
  include_context 'auto_network-settings'

  # Configure each testing environment to contain an AutoNetwork version 1 pool
  # file and a single existing machine that has been allocated in the pool
  let(:test_env) { isolated_environment }
  let(:pool_file) { test_env.homedir.join('auto_network', 'pool.yaml') }
  before(:each) do
    pool_file.dirname.mkpath
    pool_file.open('w+') do |f|
      f.write <<-EOF
--- !ruby/object:AutoNetwork::Pool
network_range: 10.20.1.0/29
pool:
  10.20.1.2: some-uuid-string
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
    machine_dir.join('id').open('w+') { |f| f.write('some-uuid-string') }
  end

  # Dispose of the temporary directory used to run the test.
  after(:each) do
    test_env.close
  end
end
