class AutoNetwork::Action::PersistentIP

  def initialize(app, env)
    @app, @env = app, env
  end

  def call(env)
    raise NotImplementedError
  end
end
