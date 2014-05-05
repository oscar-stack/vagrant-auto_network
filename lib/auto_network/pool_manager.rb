require 'auto_network/pool'
require 'auto_network/pool_storage'
require 'ipaddr'

module AutoNetwork
  # The `PoolManager` class manages the mapping between providers and pools of
  # IP addresses. Each `PoolManager` instance is backed by a file that persists
  # state and attempts to prevent race conditions between multiple Vagrant
  # processes.
  #
  # Once created, `PoolManager` instances proxy the public interface of the
  # {AutoNetwork::Pool} instances they manage. New pools will be allocated as
  # needed and all pool operations are wrapped in transactions that ensure
  # state is synced to the file system.
  #
  # @see AutoNetwork::PoolStorage The object used to implement file-based
  #   persistance for this class.
  # @see AutoNetwork::Pool The objects managed by this class.
  class PoolManager
    # Create a new `PoolManager` instance with persistent storage.
    #
    # @param path [String, Pathname] the location at which to persist the state
    #   of `AutoNetwork` pools.
    def initialize(path)
      # Ensure newly created files start with a skeleton data structure.
      AutoNetwork::PoolStorage.init(path) unless File.file?(path)
      @pool_storage = AutoNetwork::PoolStorage.new(path)
    end

    # Looks up the pool associated with the provider for a given machine and
    # sets up a transaction where the state of the pool can be safely inspected
    # or modified. If a pool does not exist for the machine provider, one will
    # automatically be created.
    #
    # @param machine [Vagrant::Machine]
    # @param read_only [Boolean] whether to create a read_only transaction.
    # @yieldparam pool [AutoNetwork::Pool]
    def with_pool_for(machine, read_only=false)
      @pool_storage.transaction(read_only) do
        pool = lookup_pool_for(machine)
        pool ||= generate_pool_for(machine)

        yield pool
      end
    end

    # {include:AutoNetwork::Pool#request}
    #
    # @see AutoNetwork::Pool#request
    def request(machine)
      with_pool_for(machine) do |pool|
        pool.request(machine)
      end
    end

    # {include:AutoNetwork::Pool#release}
    #
    # @see AutoNetwork::Pool#release
    def release(machine)
      with_pool_for(machine) do |pool|
        pool.release(machine)
      end
    end

    # {include:AutoNetwork::Pool#address_for}
    #
    # @see AutoNetwork::Pool#address_for
    def address_for(machine)
      with_pool_for(machine, read_only=true) do |pool|
        pool.address_for(machine)
      end
    end

    private

    # Retrieve the {AutoNetwork::Pool} assigned to the provider of a given
    # machine.
    #
    # @note This must be executed within a transaction.
    # @api private
    #
    # @param machine [Vagrant::Machine]
    # @return [AutoNetwork::Pool] the pool associated with the machine
    #   provider.
    # @return [nil] if no pool exists for the machine provider.
    def lookup_pool_for(machine)
      @pool_storage['pools'][machine.provider_name.to_s]
    end

    # Create an {AutoNetwork::Pool} assigned to the provider of a given
    # machine.
    #
    # @note This must be executed within a transaction.
    # @api private
    #
    # @param machine [Vagrant::Machine]
    # @return [AutoNetwork::Pool] the pool associated with the machine
    #   provider.
    def generate_pool_for(machine)
      if lookup_pool_for(machine).nil?
        @pool_storage['pools'][machine.provider_name.to_s] = AutoNetwork::Pool.new(next_pool_range)
      end

      lookup_pool_for(machine)
    end

    # Scan the list of allocated pools and determine the next usable address
    # range. Assumes all Pools use a "/24" address range and share the same
    # "/16" range.
    #
    # @note This must be executed within a transaction.
    # @api private
    #
    # @return [String] an IP range ending in "/24".
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
