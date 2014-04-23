require 'ipaddr'

module AutoNetwork
  # The Pool is a class that manages a range of IP addresses and manages the
  # allocation of specific addresses to individual Vagrant machines.
  class Pool

    # An error class raised when no allocatable addresses remain in the Pool.
    #
    # @api private
    class PoolExhaustedError < Vagrant::Errors::VagrantError
      error_key(:pool_exhausted, 'vagrant_auto_network')
    end

    # Create a new Pool object that manages a range of IP addresses.
    #
    # @param network_range [String] The network address range to use as the
    #   address pool.
    def initialize(network_range)
      @network_range = network_range
      generate_pool
    end

    # Allocate an IP address for the given machine. If a machine already has an
    # IP address allocated, then return that.
    #
    # @param machine [Vagrant::Machine]
    # @return [IPAddr] the IP address assigned to the machine.
    # @raise [PoolExhaustedError] if no allocatable addresses remain in the
    #   range managed by the pool.
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

    # Release an IP address associated with a machine.
    #
    # @param machine [Vagrant::Machine]
    # @return [nil]
    def release(machine)
      if (address = address_for(machine))
        @pool[address] = nil
      end
    end

    # Look up the address assigned to a given machine.
    #
    # @param machine [Vagrant::Machine]
    # @return [IPAddr] the IP address assigned to the machine.
    # @return [nil] if the machine has no address assigned.
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
