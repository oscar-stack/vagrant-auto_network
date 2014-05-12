shared_examples 'provider/auto_network' do |provider, options|
  if !File.file?(options[:box])
    raise ArgumentError,
      "A box file must be downloaded for provider: #{provider}. Try: rake acceptance:setup"
  end

  include_context 'acceptance'
  let(:extra_env) { options[:env_vars] }

  before do
    environment.skeleton('auto_network')
    assert_execute('vagrant', 'box', 'add', 'box', options[:box])
  end

  after do
    # Ensure any VMs that survived tests are cleaned up.
    execute('vagrant', 'destroy', '--force', log: false)
  end

  # NOTE: This is a bit tightly coupled as it strings together tests for
  # vagrant up, status, reload and destroy in a single case. However, each
  # invocation is dependant on the state created by the prior command.
  it 'manages IP address allocation for the lifecycle of a VM' do
    result = assert_execute('vagrant', 'up', "--provider=#{provider}")
    expect(result.stdout).to match(/AutoNetwork assigning "\S+" to 'default'/)

    assert_execute('vagrant', 'status')
    assert_execute('vagrant', 'reload', 'default')

    result = assert_execute('vagrant', 'destroy', '--force')
    expect(result.stdout).to match(/AutoNetwork releasing "\S+" from 'default'/)
  end
end
