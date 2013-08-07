require 'auto_network/action_helpers'

class AutoNetwork::Action::Request

  include AutoNetwork::ActionHelpers

  def initialize(app, env)
    @app, @env = app, env
  end

  def call(env)
    @env = env

    @pool    = @env[:auto_network_pool]
    @machine = @env[:machine]

    request_address if machine_needs_address?

    @app.call(@env)
  end

  private

  def machine_needs_address?
    @machine and @pool.address_for(@machine).nil?
  end

  def request_address
    auto_networks.each do |net|
      addr = @pool.request(@machine)
      @env[:ui].info "Assigning #{addr.inspect} to '#{@machine.id}'", :prefix => true
      filter_private_network(net, addr)
    end
  end
end
