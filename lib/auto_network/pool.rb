require 'ipaddr'

module AutoNetwork
  class Pool

    class PoolExhaustedError < Vagrant::Errors::VagrantError
      error_key(:pool_exhausted, 'vagrant_auto_network')
    end

    # @param network_addr [String] The network address range to use as the
    #   address pool.
    def initialize(network_range)
      @network_range = network_range
      generate_pool
    end

    # Retrieve an IP address for the given machine. If a machine already has
    # an IP address requested, then return that.
    #
    # @param machine [Vagrant::Machine]
    def request(machine)
      if (address = address_for(machine))
        return address
      elsif (address = next_available_lease)
        @pool[address] = machine.id
        return address
      else
        raise PoolExhaustedError,
          :name    => machine.name,
          :network => @network_range
      end
    end

    # Release an IP address associated with a machine
    #
    # @param machine [Vagrant::Machine]
    def release(machine)
      if (address = address_for(machine))
        @pool[address] = nil
      end
    end

    def address_for(machine)
      return nil if machine.id.nil?
      next_addr, _ = @pool.find { |(addr, id)| machine.id == id }

      next_addr
    end

    private

    def next_available_lease
      next_addr, _ = @pool.find { |(addr, id)| id.nil? }

      next_addr
    end

    def generate_pool
      network = IPAddr.new(@network_range)
      addresses = network.to_range.to_a

      addresses.delete_at(-1) # Strip out the broadcast address
      addresses.delete_at(1)  # And the first address (should be used by the host)
      addresses.delete_at(0)  # And the network address

      @pool = {}

      addresses.map(&:to_s).each do |addr|
        @pool[addr] = nil
      end
    end
  end
end
