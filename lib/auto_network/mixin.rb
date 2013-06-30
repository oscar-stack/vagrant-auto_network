require 'auto_network/pool'

module AutoNetwork
# Extension to vagrant VM configuration to automatically configure an
# internal network.
module Mixin

  def auto_network!
    pool = AutoNetwork::Pool.instance

    addr = pool.next

    network :private_network, :ip => addr
  end
end
end
