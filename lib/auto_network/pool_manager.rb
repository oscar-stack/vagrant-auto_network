require 'auto_network/pool'
require 'ipaddr'

# Manages a collection of IP address Pools. One per provider.
module AutoNetwork
  class PoolManager
    def initialize(pools = {})
      @pools = pools
    end

    # The `request`, `release` and `address_for` methods are all proxied
    # straight through to the underlying Pool objecs.
    def request(machine)
      if (pool = pool_for(machine))
        return pool.request(machine)
      else
        generate_pool_for(machine).request(machine)
      end
    end

    def release(machine)
      if (pool = pool_for(machine))
        pool.release(machine)
      else
        nil
      end
    end

    def address_for(machine)
      if (pool = pool_for(machine))
        return pool.address_for(machine)
      else
        return nil
      end
    end

    private

    def pool_for(machine)
      @pools[machine.provider_name.to_s]
    end

    def generate_pool_for(machine)
      @pools[machine.provider_name.to_s] = AutoNetwork::Pool.new(next_pool_range)
      @pools[machine.provider_name.to_s]
    end

    # A bit hacky. Assumes all Pools use a "/24" address range.
    def next_pool_range
      # Look up the highest "XX.XX.YY.XX/24" range in use.
      last_pool_range = IPAddr.new(@pools.values.map{|v| v.network_range}.sort.last)
      # Increment "YY" by one to generate a new "/24" range.
      new_pool_range = ((last_pool_range >> 8).succ << 8)

      new_pool_range.to_s + '/24'
    end
  end
end
