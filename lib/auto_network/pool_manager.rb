require 'auto_network/pool'
require 'auto_network/pool_storage'
require 'ipaddr'

# Manages a collection of IP address Pools. One per provider.
module AutoNetwork
  class PoolManager
    def initialize(path)
      AutoNetwork::PoolStorage.init(path) unless File.file?(path)
      @pool_storage = AutoNetwork::PoolStorage.new(path)
    end

    # Locates or creates a pool for the given machine and yields the pool to a
    # block. This is all done inside of a transaction so that the pool may be
    # safely modified.
    def with_pool_for(machine, read_only=false)
      @pool_storage.transaction(read_only) do
        pool = lookup_pool_for(machine)
        pool ||= generate_pool_for(machine)

        yield pool
      end
    end

    # The `request`, `release` and `address_for` methods are all proxied
    # straight through to the underlying Pool objecs.
    def request(machine)
      with_pool_for(machine) do |pool|
        pool.request(machine)
      end
    end

    def release(machine)
      with_pool_for(machine) do |pool|
        pool.release(machine)
      end
    end

    def address_for(machine)
      with_pool_for(machine, read_only=true) do |pool|
        pool.address_for(machine)
      end
    end

    private

    # NOTE: All private methods must be executed within a transaction.

    def lookup_pool_for(machine)
      @pool_storage['pools'][machine.provider_name.to_s]
    end

    def generate_pool_for(machine)
      @pool_storage['pools'][machine.provider_name.to_s] = AutoNetwork::Pool.new(next_pool_range)
      @pool_storage['pools'][machine.provider_name.to_s]
    end

    # A bit hacky. Assumes all Pools use a "/24" address range.
    def next_pool_range
      # Fetch the list of pools under management. Return nil if no pools exist.
      pools = @pool_storage.fetch('pools', nil)

      if pools.empty?
        # If no pools have been created, use the default range.
        AutoNetwork.default_pool
      else
        # Look up the highest "XX.XX.YY.XX/24" range in use.
        last_pool_range = IPAddr.new(pools.values.map{|v| v.network_range}.sort.last)
        # Increment "YY" by one to generate a new "/24" range.
        ((last_pool_range >> 8).succ << 8).to_s + '/24'
      end
    end
  end
end
