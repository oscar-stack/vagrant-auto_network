require 'auto_network/pool'

module AutoNetwork
  # Extension to vagrant VM configuration to automatically configure an
  # internal network.
  module Mixin
    def auto_network!
      puts "AutoNetwork::Mixin is deprecated, use config.vm.network :private_network, :auto_network => true"
      network :private_network, :auto_network => true
    end
  end
end
