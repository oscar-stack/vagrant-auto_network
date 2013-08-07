require 'auto_network/action_helpers'

class AutoNetwork::Action::FilterNetworks

  include AutoNetwork::ActionHelpers

  def initialize(app, env)
    @app, @env = app, env
  end


  # Convert auto_network interfaces to static private_network interfaces.
  #
  # @param env [Hash]
  #
  # @option env [AutoNetwork::Pool] auto_network_pool The global auto network pool
  # @option env [Vagrant::Environment] env The Vagrant environment containing
  #   the active machines that need to be filtered.
  #
  # @return [void]
  def call(env)
    @env = env

    @pool      = @env[:auto_network_pool]
    global_env = @env[:env]


    machines = machines_for_env(global_env)

    active_machines.each do |m|
      @machine = m
      assign_address if machine_has_address?
    end
    @machine = nil

    @app.call(@env)
  end

  private

  def machines_for_env(global_env)
    global_env.active_machines.map { |vm_id| global_env.machine(*vm_id) }
  end

  def machine_has_address?
    @machine and @pool.address_for(@machine)
  end

  def assign_address
    auto_networks.each do |net|
      addr = @pool.address_for(@machine)
      @env[:ui].info "Reassigning #{addr.inspect} to #{@machine.id}", :prefix => true
      filter_private_network(net, addr)
    end
  end
end
