require 'auto_network'

require 'ipaddr'

module AutoNetwork
  class Pool

    class PoolExhaustedError < Vagrant::Errors::VagrantError; end

    # @param network_addr [String] The network address range to use as the
    #   address pool. Defaults to `AutoNetwork.default_pool`
    def initialize(network_addr = AutoNetwork.default_pool)
      generate_pool(network_addr)
    end

    def request(machine)
      if (address = address_for_machine(machine))
        return address
      elsif (address = next_available_lease)
        @pool[address] = machine.id
        return address
      else
        raise PoolExhaustedError
      end
    end

    def release(machine)
      raise NotImplementedError
    end

    private

    def address_for_machine(machine)
      next_addr, _ = @pool.find { |(addr, id)| machine.id == id }

      next_addr
    end

    def next_available_lease
      next_addr, _ = @pool.find { |(addr, id)| id.nil? }

      next_addr
    end

    def generate_pool(str)
      network = IPAddr.new(str)
      addresses = network.to_range.to_a

      addresses.delete_at(-1)
      addresses.delete_at(0)

      @pool = {}

      addresses.map(&:to_s).each do |addr|
        @pool[addr] = nil
      end
    end
  end
end
