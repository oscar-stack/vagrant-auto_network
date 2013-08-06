class AutoNetwork::Action::GenPool

  def initialize(app, env)
    @app, @env = app, env
  end

  def call(env)
    @env = env

    deserialize!
    @app.call(@env)
    serialize!
  end

  private

  def deserialize!
    pool = nil
    if statefile.exist?
      yaml = statefile.read
      pool = YAML.load(statefile.read)
    else
      pool = AutoNetwork::Pool.new
    end
    @env[:auto_network_pool] = pool
  end

  def serialize!
    data = YAML.dump(@env[:auto_network_pool])

    statefile.open('w') do |fh|
      fh.write(data)
    end
  end

  def statefile
    @statefile ||= @env[:home_path].join('auto_network.yaml')
  end
end
