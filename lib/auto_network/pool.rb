require 'auto_network'

require 'ipaddress'

module AutoNetwork
  class Pool

    class PoolExhaustedError < Vagrant::Errors::VagrantError; end

    # @param addr [String] The network address range to use as the address pool.
    #   Defaults to `AutoNetwork.default_pool`
    def initialize(addr = AutoNetwork.default_pool)
      @addr    = addr
      @network = IPAddress.parse(addr)

      @range = @network.hosts
      # Drop the first IP address as it should be reserved for the host system
      @range.shift
    end

    # @return [String] The string representation of the next available address
    # @raise [PoolExhaustedError] There are no remaining addresses in the pool.
    def next
      if @range.empty?
        raise PoolExhaustedError, "No addresses remaining in network address pool #{addr.inspect}"
      end

      addr = @range.shift
      addr.address
    end
  end
end
