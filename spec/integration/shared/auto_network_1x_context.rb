require_relative 'auto_network_integration_context'

# Creates an environment for each test containing a small pool of AutoNetwork
# addresses.
shared_context 'auto_network 1.x' do
  let(:pool_file_content) { <<-EOF }
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

  include_context 'auto_network integration'

end
