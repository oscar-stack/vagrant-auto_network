require 'auto_network/mixin'

module AutoNetwork
  class << self
    def default_pool
      @default_pool ||= '10.20.1.0/24'
    end

    def default_pool=(pool)
      @default_pool = pool
    end
  end
end
