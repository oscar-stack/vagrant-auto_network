require 'pathname'
require 'yaml/store'
require 'auto_network/pool'

module AutoNetwork
  # This is a specialized subclass of `YAML::Store` that manages data
  # persistence for {AutoNetwork::PoolManager} instances.
  #
  # In addition to managing serialization, the `YAML::Store` parent class also
  # provides facilities for synchronizing state across multiple Vagrant
  # processes. This subclass adds functionality for handling upgrades when the
  # AutoNetwork serialization format changes.
  #
  # Format history:
  #
  #   - **Version 1:** A single instance of {AutoNetwork::Pool} instance
  #     serialized to YAML. Never formalized with a version number.
  #
  #   - **Version 2:** A hash containing a `poolfile_version` set to `2` and a
  #     `pools` sub-hash with keys created from Vagrant provider names and
  #     values of a single {AutoNetwork::Pool} instance serialized to YAML.
  #
  # @example Version 1
  #   --- !ruby/object:AutoNetwork::Pool
  #   # Single serialized AutoNetwork::Pool
  #
  # @example Version 2
  #   ---
  #   poolfile_version: 2
  #   pools:
  #     some_vagrant_provider_name: !ruby/object:AutoNetwork::Pool
  #       # Single serialized AutoNetwork::Pool
  class PoolStorage < YAML::Store
    # An integer indicating the current AutoNetwork serialization format.
    POOLFILE_VERSION = 2

    # The data structure that {AutoNetwork::PoolManager} instances
    # expect to be available in all pool files.
    POOLFILE_SKELETON =  {
      'poolfile_version' => POOLFILE_VERSION,
      'pools' => {},
    }

    # Creates a new pool file at a target location and fills it with default
    # data.
    #
    # @see POOLFILE_SKELETON
    #
    # @param path [String, Pathname] the location of the new pool file.
    # @return [void]
    def self.init(path)
      path = Pathname.new(path)
      dir = path.dirname

      dir.mkpath unless dir.exist?
      File.write(path, POOLFILE_SKELETON.to_yaml)
    end

    private

    # Override the method inherited from `YAML::Store`. All `PStore` instances
    # expect `load` to strictly return a `Hash`. This override allows us to
    # perform on-the-fly upgrading of data loaded from old pool files and
    # ensure the right structure is returned.
    #
    # @api private
    #
    # @param content [String] serialized YAML read from the pool file.
    # @return [Hash]
    def load(content)
      data = super(content)

      if data.is_a? AutoNetwork::Pool
        upgrade_from_version_1! data
      else
        data
      end
    end

    # The loosely defined "version 1" of the pool file just serialized a single
    # {AutoNetwork::Pool} object. All AutoNetwork releases that used Version 1
    # files only supported the Vagrant VirtualBox provider, so we return a new
    # Hash-based data structure that assigns the old Pool to the `virtualbox`
    # provider.
    #
    # @api private
    #
    # @param data [AutoNetwork::Pool] the old pool object.
    # @return [Hash] a hash conforming to the current {POOLFILE_VERSION}.
    def upgrade_from_version_1!(data)
      {
        'poolfile_version' => POOLFILE_VERSION,
        'pools' => {
          'virtualbox' => data,
        },
      }
    end
  end
end
