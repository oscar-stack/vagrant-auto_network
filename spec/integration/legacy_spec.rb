require 'spec_helper'
require_relative 'shared/auto_network_0x_context'

describe 'Working with AutoNetwork 0.x data' do
  include_context 'vagrant-unit'
  include_context 'auto_network 0.x'

  def current_ip(machine)
    settings.pool_manager.with_pool_for(machine) {|p| p.address_for(machine)}
  end

  before(:each) do
    env = test_env.create_vagrant_env
    @test_machine = env.machine(:test1, :dummy)

    # Legacy pool data is assigned to the VirtualBox provider. Fake our
    # provider name for this purpose.
    allow(@test_machine).to receive(:provider_name).and_return(:virtualbox)
  end

  it 'upgrades the poolfile format when saving data' do
    # Running a read/write transaction will cause the poolfile to be
    # regenerated.
    settings.pool_manager.with_pool_for(@test_machine, read_only=false){|p| }
    pool_data = YAML.load_file(pool_file)

    # Expect that the poolfile has been upgraded to the latest version.
    expect(pool_data).to include({
      'poolfile_version' => AutoNetwork::PoolStorage::POOLFILE_VERSION
    })
  end

  # The 0.x context defines one machine with an IP allocated by UUID.
  it 'releases IP addresses allocated by UUID' do
    expect(current_ip(@test_machine)).to eq('10.20.1.2')

    @test_machine.action(:destroy)

    expect(current_ip(@test_machine)).to be_nil
  end
end
