shared_examples 'provider/auto_network' do |provider, options|
  if !File.file?(options[:box])
    raise ArgumentError,
      "A box file must be downloaded for provider: #{provider}. Try: rake acceptance:setup"
  end

  include_context 'acceptance'

  before do
    environment.skeleton('auto_network')
    assert_execute('vagrant', 'box', 'add', 'box', options[:box])
  end

  after do
    assert_execute('vagrant', 'destroy', '--force', log: false)
  end

  it 'manages IP address allocation for the lifecycle of a VM' do
    result = execute('vagrant', 'up', "--provider=#{provider}")
    expect(result).to exit_with(0)
    expect(result.stdout).to match(/Assigning "10\.42\.1\.2" to 'default'/)

    result = execute('vagrant', 'destroy', '--force', log: false)
    expect(result).to exit_with(0)
    expect(result.stdout).to match(/Releasing "10\.42\.1\.2" from default/)
  end
end
