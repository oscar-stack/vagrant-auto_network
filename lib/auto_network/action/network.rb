require 'auto_network/pool'

class AutoNetwork::Action::Network

  def initialize(app, env)
    @app, @env = app, env
  end

  def call(env)
    @env = env

    @machine_config = @env[:machine].config.vm

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
    @interfaces = @machine_config.networks.select do |(net_type, options)|
      net_type == :private_network and options[:auto_network]
    end
  end

  # Convert an auto network to a private network with a static IP address.
  #
  # @param iface [Array<Symbol, Hash>]
  #
  # @return [void]
  def mk_private_network(iface)
    addr = pool.next

    iface[1].delete(:auto_network)
    iface[1][:ip] = addr
  end

  def pool
    AutoNetwork::Pool.instance
  end
end
