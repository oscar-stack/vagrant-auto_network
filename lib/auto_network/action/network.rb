require 'auto_network/pool'

class AutoNetwork::Action::Network

  def initialize(app, env)
    @app, @env = app, env
  end

  def call(env)
    @env = env

    @machine = @env[:machine]
    @machine_config = @machine.config.vm

    @pool = @env[:auto_network_pool]

    auto_networks.each do |net|
      mk_private_network(net)
    end

    @app.call(@env)
  end

  private

  # Fetch all private networks that are tagged for auto networking
  #
  # @param iface [Array<Symbol, Hash>]
  def auto_networks
    @machine_config.networks.select do |(net_type, options)|
      net_type == :private_network and options[:auto_network]
    end
  end

  # Convert an auto network to a private network with a static IP address.
  #
  # This does an in-place modification of the private_network options hash
  # to strip out the auto_network configuration and make this behave like a
  # normal private network interface with a static IP address.
  #
  # @param iface [Array<Symbol, Hash>]
  #
  # @return [void]
  def mk_private_network(iface)
    addr = @pool.request(@machine)

    @env[:ui].info "Automatically assigning IP address #{addr.inspect}", :prefix => true

    iface[1].delete(:auto_network)
    iface[1][:ip] = addr
  end
end
