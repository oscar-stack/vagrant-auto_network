module AutoNetwork::DefaultPool
  def default_pool
    @default_pool ||= '10.20.1.0/24'
  end

  def default_pool=(pool)
    @default_pool = pool
  end
end
