module AutoNetwork
  module ActionHelpers

    # Fetch all private networks that are tagged for auto networking
    #
    # @param iface [Array<Symbol, Hash>]
    def auto_networks
      @machine.config.vm.networks.select do |(net_type, options)|
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
