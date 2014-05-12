require 'auto_network/action/base'

class AutoNetwork::Action::Release < AutoNetwork::Action::Base
  # Release auto_network IP address on VM destruction
  #
  # @param env [Hash]
  #
  # @option env [AutoNetwork::Pool] auto_network_pool The global auto network pool
  # @option env [Vagrant::Machine] machine The Vagrant machine being destroyed
  #
  # @return [void]
  def call(env)
    @env = env

    @machine = @env[:machine]

    release_network_addresses if machine_has_address?(@machine)

    @app.call(@env)
  end

  private

  def release_network_addresses
    addr = AutoNetwork.active_pool_manager.address_for(@machine)
    @env[:ui].info "AutoNetwork releasing #{addr.inspect} from '#{@machine.name}'",
      :prefix => true
    AutoNetwork.active_pool_manager.release(@machine)
  end
end
