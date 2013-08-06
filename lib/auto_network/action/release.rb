class AutoNetwork::Action::Release

  def initialize(app, env)
    @app, @env = app, env
  end

  def call(env)
    @env = env

    @machine = @env[:machine]
    @machine_config = @machine.config.vm

    @pool = @env[:auto_network_pool]

    auto_networks.each do |net|
      release_private_network(net)
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

  def release_private_network(_)
    @pool.release(@machine)
  end
end
