class AutoNetwork::Action::GenPool

  def initialize(app, env)
    @app, @env = app, env
  end

  def call(env)
    @env = env

    @env[:auto_network_pool] = AutoNetwork::Pool.new

    @app.call(@env)
  end

end
