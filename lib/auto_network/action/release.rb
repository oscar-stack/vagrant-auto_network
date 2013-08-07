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

    if (addr = @pool.address_for(@machine))
      @env[:ui].info "Releasing #{addr.inspect} from #{@machine.id}", :prefix => true
      @pool.release(@machine)
    end
  end

  def env_has_machine?
    !!(@env[:machine])
  end
end
