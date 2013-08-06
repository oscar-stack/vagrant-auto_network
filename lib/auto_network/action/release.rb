class AutoNetwork::Action::Release

  def initialize(app, env)
    @app, @env = app, env
  end

  def call(env)
    @env = env
    release_network_addresses if env_has_machine?
    @app.call(@env)
  end

  private

  def release_network_addresses
    @machine = @env[:machine]
    @machine_config = @machine.config.vm

    @pool = @env[:auto_network_pool]

    auto_networks.each do |net|
      release_private_network(net)
    end
  end


  def env_has_machine?
    !!(@env[:machine])
  end

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
