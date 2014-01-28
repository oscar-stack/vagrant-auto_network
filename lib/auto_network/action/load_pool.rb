require 'auto_network'
require 'yaml'

class AutoNetwork::Action::LoadPool

  def initialize(app, env)
    @app, @env = app, env
  end

  # Handle the loading and unloading of the auto_network pool
  #
  # @param env [Hash]
  #
  # @option env [AutoNetwork::Pool] auto_network_pool The global auto network pool
  # @option env [Vagrant::Environment] env The Vagrant environment containing
  #   the active machines that need to be filtered.
  #
  # @return [void]
  def call(env)
    @env = env

    if env_ready?
      setup_ivars
      deserialize!
      @app.call(@env)
      serialize!
    else
      @app.call(@env)
    end
  end

  private

  def env_ready?
    !!@env[:home_path]
  end

  def setup_ivars
    @config_path = @env[:home_path].join('auto_network')
    @statefile   = @config_path.join('pool.yaml')
  end

  def deserialize!
    pool = nil
    if @statefile.exist?
      pool = YAML.load(@statefile.read)
    else
      range = AutoNetwork.default_pool
      @env[:ui].info "No auto_network pool available, generating a pool with the range #{range}"
      pool = AutoNetwork::Pool.new(range)
    end
    @env[:auto_network_pool] = pool
  end

  def serialize!
    @config_path.mkpath unless @config_path.exist?

    pool_data = YAML.dump(@env[:auto_network_pool])
    @statefile.open('w') { |fh| fh.write(pool_data) }
  end
end
