module AutoNetwork
  module ActionHelpers

    # Determine if the given machine exists and has an auto_network address
    #
    # @param [Vagrant::Machine]
    #
    # @return [true, false]
    def machine_has_address?(machine)
      !!(machine and AutoNetwork.pool_manager.address_for(machine))
    end

    # Fetch all private networks that are tagged for auto networking
    #
    # @param iface [Array<Symbol, Hash>]
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
