require 'ipaddr'
require 'vagrant/errors'

module AutoNetwork
  # This module is used by AutoNetwork to store global state when running under
  # Vagrant. This module is mixed into the top-level AutoNetwork namespace.
  module Settings

    # An error class raised when an invalid value is assigned to a setting.
    #
    # @api private
    class InvalidSettingErrror < Vagrant::Errors::VagrantError
      error_key(:invalid_setting, 'vagrant_auto_network')
    end

    # @!attribute [rw] pool_manager
    #   @return [AutoNetwork::PoolManager, nil]
    attr_accessor :pool_manager

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
    # @raise [InvalidSettingErrror] if an IPAddr object cannot be initialized
    #   from the value of pool.
    # @return [void]
    def default_pool=(pool)
      # Ensure the pool is valid.
      begin
        IPAddr.new pool
      rescue ArgumentError
        raise InvalidSettingErrror,
          :setting_name => 'default_pool',
          :value => pool
      end

      @default_pool = pool
    end
  end
end
