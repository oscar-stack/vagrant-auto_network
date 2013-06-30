require 'ipaddress'

module AutoNetwork
class Pool

  # @todo remove hack.
  def self.instance
    @myself ||= new
  end

  def initialize(range = '10.20.1.0/24')
    @network  = IPAddress.parse(range)
    @iterator = @network.hosts.each
    @iterator.next
  end

  def next
    @iterator.next.address
  end
end
end
