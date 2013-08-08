require 'auto_network/action_helpers'

class AutoNetwork::Action::Request

  include AutoNetwork::ActionHelpers

  def initialize(app, env)
    @app, @env = app, env
  end

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

    @pool    = @env[:auto_network_pool]
    @machine = @env[:machine]

    request_address unless machine_has_address?(@machine)

    @app.call(@env)
  end

  private

  def request_address
    machine_auto_networks(@machine).each do |net|
      addr = @pool.request(@machine)
      @env[:ui].info "Assigning #{addr.inspect} to '#{@machine.id}'", :prefix => true
      filter_private_network(net, addr)
    end
  end
end
