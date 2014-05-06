require 'pathname'
require 'yaml/store'
require 'auto_network/pool'

module AutoNetwork
  # This is a specialized subclass of `YAML::Store` that knows how to
  # initialize and upgrade AutoNetwork Pool files.
  #
  # @api private
  class PoolStorage < YAML::Store
    POOLFILE_VERSION = 2
    POOLFILE_SKELETON =  {
      'poolfile_version' => POOLFILE_VERSION,
      'pools' => {},
    }

    # Creates a new pool file at a target location and fills it with default
    # data.
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

    # Override the method inherited from `YAML::Store`. All `PStore` object
    # expect load to strictly return a `Hash`. This override allows us to
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
    # Hash-based data structure that includes the old Pool.
    #
    # @api private
    #
    # @param data [AutoNetwork::Pool] the old pool object.
    # @return [Hash] a hash containing the old pool object.
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
