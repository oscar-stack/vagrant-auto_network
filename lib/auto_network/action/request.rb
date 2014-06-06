require 'auto_network/action/base'


# @todo This action should be renamed. It is more like a "pre-validation
#   filter" than something that only fires during machine creation.
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

    machine = @env[:machine]

    # Move along if this machine has no AutoNetwork interfaces.
    @app.call(@env) if machine_auto_networks(machine).empty?

    addr = AutoNetwork.active_pool_manager.address_for(machine)
    if addr.nil?
      addr = AutoNetwork.active_pool_manager.request(machine)
      @env[:ui].info "AutoNetwork assigning #{addr.inspect} to '#{machine.name}'",
        :prefix => true
    end

    filter_networks(machine, addr)

    @app.call(@env)
  end

  private

  def filter_networks(machine, addr)
    machine_auto_networks(machine).each do |net|
      filter_private_network(net, addr)
    end
  end
end
