require 'auto_network/action_helpers'
require 'log4r'

class AutoNetwork::Action::FilterNetworks

  include AutoNetwork::ActionHelpers

  def initialize(app, env)
    @app, @env = app, env

    @logger = Log4r::Logger.new('vagrant::auto_network::filter_networks')
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

    @pool       = @env[:auto_network_pool]
    @global_env = @env[:env]

    filter if has_working_env?

    @app.call(@env)
  end

  private

  def has_working_env?
    !!(@global_env.local_data_path)
  end

  def filter
    machines_for_env.each do |machine|
      assign_address(machine) if machine_has_address?(machine)
    end
  end

  def machines_for_env
    @global_env.active_machines.map { |vm_id| @global_env.machine(*vm_id) }
  end

  def assign_address(machine)
    machine_auto_networks(machine).each do |net|
      addr = @pool.address_for(machine)
      @logger.info "Reassigning #{addr.inspect} to existing machine #{machine.name}"
      filter_private_network(net, addr)
    end
  end
end
