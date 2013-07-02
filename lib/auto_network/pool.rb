require 'auto_network'

require 'ipaddress'

module AutoNetwork
class Pool

  # @todo remove hack.
  def self.instance
    @myself ||= new
  end

  def initialize(range = AutoNetwork.default_pool)
    @network  = IPAddress.parse(range)
    @iterator = @network.hosts.each

    # Assume that the first valid host address is used by the host address.
    @iterator.next
  end

  def next
    @iterator.next.address
  end
end
end
