module AutoNetwork
  # This is an abstract base class for AutoNetwork actions that provides
  # helper methods for interfacing with a {AutoNetwork::PoolManager} object
  # and the {AutoNetwork::Pool} instances it manages.
  #
  # @abstract Subclass and override {#call} to implement a new AutoNetwork
  #   action.
  class Action::Base
    # Create a new action instance that is suitable for execution as part of
    # Vagrant middleware.
    #
    # @param app [#call] an instance of an object that responds to `call`.
    #   Typically an object representing a chain of Vagrant actions.
    #   Executing `call` passes execution to the next action in the chain.
    # @param env [Hash] a hash representing the Vagrant state this action
    #   executes under. Unfortunately, there are two or three variations of
    #   what data can be passed, so Action logic that inspects this parameter
    #   is a bit fragile.
    def initialize(app, env)
      @app, @env = app, env
    end

    def call(env)
      raise NotImplementedError
    end

    protected

    # Determine if the given machine exists and has an auto_network address
    #
    # @param machine [Vagrant::Machine]
    #
    # @return [true, false]
    def machine_has_address?(machine)
      !!(machine and AutoNetwork.pool_manager.address_for(machine))
    end

    # Fetch all private networks that are tagged for auto networking
    #
    # @param machine [Vagrant::Machine]
    #
    # @return [Array<Symbol, Hash>] All auto_networks
    def machine_auto_networks(machine)
      machine.config.vm.networks.select do |(net_type, options)|
        net_type == :private_network and options[:auto_network]
      end
    end

    # Convert an auto network to a private network with a static IP address.
    #
    # This does an in-place modification of the private_network options hash
    # to strip out the auto_network configuration and make this behave like a
    # normal private network interface with a static IP address.
    #
    # @param iface [Array<Symbol, Hash>]
    # @param addr [String] The static IP address to assign to the private network
    #
    # @return [void]
    def filter_private_network(iface, addr)
      opts = iface[1]
      opts.delete(:auto_network)
      opts[:ip] = addr
    end
  end
end
