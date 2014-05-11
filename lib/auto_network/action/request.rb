require 'auto_network/action/base'

class AutoNetwork::Action::Request < AutoNetwork::Action::Base
  # Request an auto_network IP address on VM creation
  #
  # @param env [Hash]
  #
  # @option env [AutoNetwork::Pool] auto_network_pool The global auto network pool
  # @option env [Vagrant::Machine] machine The Vagrant machine being created
  #
  # @return [void]
  def call(env)
    @env = env

    @machine = @env[:machine]

    request_address unless machine_has_address?(@machine)

    @app.call(@env)
  end

  private

  def request_address
    machine_auto_networks(@machine).each do |net|
      addr = AutoNetwork.pool_manager.request(@machine)
      @env[:ui].info "Assigning #{addr.inspect} to '#{@machine.name}'", :prefix => true
      filter_private_network(net, addr)
    end
  end
end
