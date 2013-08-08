require 'auto_network/action_helpers'

class AutoNetwork::Action::Release

  include AutoNetwork::ActionHelpers

  def initialize(app, env)
    @app, @env = app, env
  end

  def call(env)
    @env = env

    @machine = @env[:machine]
    @pool    = @env[:auto_network_pool]

    release_network_addresses if machine_has_address?(@machine)

    @app.call(@env)
  end

  private

  def release_network_addresses
    addr = @pool.address_for(@machine)
    @env[:ui].info "Releasing #{addr.inspect} from #{@machine.id}", :prefix => true
    @pool.release(@machine)
  end
end
