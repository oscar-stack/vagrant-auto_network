require 'yaml/store'

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
      File.write(path, POOLFILE_SKELETON.to_yaml)
    end
  end
end
