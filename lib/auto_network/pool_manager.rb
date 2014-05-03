require 'auto_network/pool'
require 'yaml/store'
require 'ipaddr'

# Manages a collection of IP address Pools. One per provider.
module AutoNetwork
  class PoolManager
    def initialize(path)
      @pool_storage = YAML::Store.new(path)
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

    # NOTE: Both lookup_pool_for and generate_pool_for *must* be called from
    # within a transaction.

    def lookup_pool_for(machine)
      @pool_storage['pools'][machine.provider_name.to_s]
    end

    def generate_pool_for(machine)
      @pool_storage['pools'][machine.provider_name.to_s] = AutoNetwork::Pool.new(next_pool_range)
      @pool_storage['pools'][machine.provider_name.to_s]
    end

    # A bit hacky. Assumes all Pools use a "/24" address range.
    def next_pool_range
      # Look up the highest "XX.XX.YY.XX/24" range in use.
      last_pool_range = IPAddr.new(@pool_storage['pools'].values.map{|v| v.network_range}.sort.last)
      # Increment "YY" by one to generate a new "/24" range.
      new_pool_range = ((last_pool_range >> 8).succ << 8)

      new_pool_range.to_s + '/24'
    end
  end
end
