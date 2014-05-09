require 'auto_network/action_helpers'

class AutoNetwork::Action::Release

  include AutoNetwork::ActionHelpers

  def initialize(app, env)
    @app, @env = app, env
  end

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
    addr = AutoNetwork.pool_manager.address_for(@machine)
    @env[:ui].info "Releasing #{addr.inspect} from #{@machine.name}", :prefix => true
    AutoNetwork.pool_manager.release(@machine)
  end
end
