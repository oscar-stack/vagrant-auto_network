require 'vagrant'

module AutoNetwork
  class Command < Vagrant.plugin('2', :command)

    def initialize(argv, env)
      super
      @main_args, @subcommand, @sub_args = split_main_and_subcommand(argv)
      register_subcommands
    end

    def execute
      if @subcommand and (klass = @subcommands.get(@subcommand))
        klass.new(@argv, @env).execute
      elsif @subcommand
        raise "Unrecognized subcommand #{@subcommand}"
      else
        print_help
      end
    end

    private

    def register_subcommands
      @subcommands = Vagrant::Registry.new

      @subcommands.register('purge') do
        require_relative 'command/purge'
        AutoNetwork::Command::Purge
      end
    end

    def print_help
      cmd = 'vagrant auto-network'
      opts = OptionParser.new do |opts|
        opts.banner = "Usage: #{cmd} <command> [<args>]"
        opts.separator ""
        opts.separator "Available subcommands:"

        # Add the available subcommands as separators in order to print them
        # out as well.
        keys = []
        @subcommands.each { |key, value| keys << key.to_s }

        keys.sort.each do |key|
          opts.separator "     #{key}"
        end

        opts.separator ""
        opts.separator "For help on any individual command run `#{cmd} COMMAND -h`"
      end

      @env.ui.info(opts.help, :prefix => false)
    end
  end
end
