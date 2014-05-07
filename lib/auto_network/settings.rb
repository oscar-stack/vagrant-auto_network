module AutoNetwork
  # This module is used by AutoNetwork to store global state when running under
  # Vagrant. This module is mixed into the top-level AutoNetwork namespace.
  module Settings
    # Unless overriden, this will be the IP range assigned to the very first
    # {AutoNetwork::Pool} created by {AutoNetwork::PoolManager} instances.
    DEFAULT_POOL = '10.20.1.0/24'

    # Retrieve the default pool that {AutoNetwork::PoolManager} instances will
    # assign to the first {AutoNetwork::Pool} they create.
    #
    # @return [String]
    def default_pool
      @default_pool ||= DEFAULT_POOL
    end

    # Set the default pool to a new IP range.
    #
    # @param pool [String]
    # @return [void]
    def default_pool=(pool)
      @default_pool = pool
    end
  end
end
