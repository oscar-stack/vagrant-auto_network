require 'vagrant/version'
require 'rubygems/version'

# Check for deprecated Vagrant versions
module AutoNetwork
  module Action
    class VersionCheck
      MINIMUM_VERSION = '1.8.0'

      def initialize(app, env)
        @app = app
      end

      def call(env)
        unless Gem::Version.new(Vagrant::VERSION) > Gem::Version.new(MINIMUM_VERSION)
          env[:env].ui.warn I18n.t(
            'vagrant_auto_network.action.version_check.deprecated_vagrant_version',
            minimum_version: MINIMUM_VERSION,
            vagrant_version: Vagrant::VERSION
          )
        end

        @app.call(env)
      end
    end
  end
end
