$LOAD_PATH.unshift File.expand_path('lib', __dir__)

# Prevent tests from attempting to load plugins from a Vagrant install
# that may exist on the host system. We load required plugins below.
ENV['VAGRANT_DISABLE_PLUGIN_INIT'] = '1'

require 'pathname'
require 'vagrant-spec/acceptance'
require 'vagrant-auto_network'

Vagrant::Spec::Acceptance.configure do |c|
  acceptance_dir = Pathname.new File.expand_path('acceptance', __dir__)

  c.component_paths = [acceptance_dir.to_s]
  c.skeleton_paths = [(acceptance_dir + 'skeletons').to_s]

  c.provider 'virtualbox',
    box: (acceptance_dir + 'artifacts' + 'virtualbox.box').to_s,
    env_vars: {
      'VBOX_USER_HOME' => '{{homedir}}',
      'AUTO_NETWORK_TEST_RANGE' => '10.42.1.0/24',
    }

  # VMware Fusion disabled by default. Instructions:
  #   https://github.com/adrienthebo/vagrant-auto_network/wiki#vmware-fusion

  #c.provider 'vmware_fusion',
  #  box: (acceptance_dir + 'artifacts' + 'vmware_fusion.box').to_s,
  #  env_vars: {
  #    'AUTO_NETWORK_TEST_RANGE' => '10.42.2.0/24',
  #  }
end
