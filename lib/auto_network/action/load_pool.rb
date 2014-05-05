require 'auto_network'

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
    @env[:auto_network_pool] = AutoNetwork::PoolManager.new(@statefile)
  end
end
