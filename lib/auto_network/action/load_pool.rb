require 'auto_network'
require 'yaml'

class AutoNetwork::Action::LoadPool

  def initialize(app, env)
    @app, @env = app, env

    @config_path = @env[:home_path].join('auto_network')
    @statefile   = @config_path.join('pool.yaml')
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
    if @statefile.exist?
      pool = YAML.load(@statefile.read)
    else
      pool = AutoNetwork::Pool.new(AutoNetwork.default_pool)
    end
    @env[:auto_network_pool] = pool
  end

  def serialize!
    data = YAML.dump(@env[:auto_network_pool])

    @config_path.mkpath unless @config_path.exist?

    @statefile.open('w') do |fh|
      fh.write(data)
    end
  end
end
