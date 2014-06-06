require_relative 'auto_network_integration_context'

# Creates an environment for each test containing data that would have been
# created by an installation of AutoNetwork 0.x.
shared_context 'auto_network 0.x' do
  let(:pool_file_content) { <<-EOF }
--- !ruby/object:AutoNetwork::Pool
network_range: 10.20.1.0/29
pool:
  10.20.1.2: some-uuid-string
  10.20.1.3: 
  10.20.1.4: 
  10.20.1.5: 
  10.20.1.6: 
EOF

  include_context 'auto_network integration'

end
