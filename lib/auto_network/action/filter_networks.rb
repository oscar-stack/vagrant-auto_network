require 'auto_network/action_helpers'

class AutoNetwork::Action::FilterNetworks

  include AutoNetwork::ActionHelpers

  def initialize(app, env)
    @app, @env = app, env
  end

  def call(env)
    @env = env

    @pool    = @env[:auto_network_pool]

    global_env = @env[:env]

    if global_env
      active_machines = global_env.active_machines.map do |vm_id|
        global_env.machine(*vm_id)
      end

      active_machines.each do |m|
        @machine = m
        assign_address if machine_has_address?
      end
      @machine = nil
    end

    @app.call(@env)
  end

  private

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
