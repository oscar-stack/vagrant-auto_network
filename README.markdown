Vagrant Auto-network
====================

Automatically configure Vagrant private network interfaces.

[![Build Status](https://travis-ci.org/oscar-stack/vagrant-auto_network.svg?branch=master)](https://travis-ci.org/oscar-stack/vagrant-auto_network)

Summary
-------

Adding a private network address for vagrant machines generally requires
manually entering network interfaces and IP addresses for each machine, and
adding or removing machines means updating private network interfaces to make
sure that new machines don't collide. Alternately one can run a full blown DHCP
server but this is not necessarily portable and requires significant preparation
on top of Vagrant.

This plugin registers an internal address range and assigns unique IP addresses
for each successive request so that network configuration is entirely hands off.
It's much lighter than running a DNS server and masks the underlying work of
manually assigning addresses.


Installation
------------

```bash
vagrant plugin install vagrant-auto_network
```

Usage
-----

```ruby
Vagrant.configure('2') do |config|
  config.vm.define 'first' do |node|
    node.vm.box = 'centos/7'

    node.vm.network :private_network, :auto_network => true
  end

  config.vm.define 'second' do |node|
    node.vm.box = 'centos/7'

    node.vm.network :private_network, :auto_network => true
  end
end
```


Troubleshooting
---------------

On occasion, the state file AutoNetwork uses to store allocated IP addresses
can become corrupted resulting in errors similar to:

```
/opt/vagrant/embedded/lib/ruby/2.0.0/psych.rb:205:in `parse': (<unknown>): could not find expected ':' while scanning a simple key at line 288 column 7 (Psych::SyntaxError)
    from /opt/vagrant/embedded/lib/ruby/2.0.0/psych.rb:205:in `parse_stream'
    from /opt/vagrant/embedded/lib/ruby/2.0.0/psych.rb:153:in `parse'
    from /opt/vagrant/embedded/lib/ruby/2.0.0/psych.rb:129:in `load'
    from /opt/vagrant/embedded/lib/ruby/2.0.0/yaml/store.rb:61:in `load'
    from ~/.vagrant.d/gems/gems/vagrant-auto_network-1.0.2/lib/auto_network/pool_storage.rb:73:in `load'
```

This can be fixed by clearing the state file:

    rm ~/.vagrant.d/auto_network/pool.yaml

The `vagrant reload` command should be run on any VMs using AutoNetwork IPs
in order to re-issue new IP addresses.


Caveats
-------

The default pool range has been hardcoded as '10.20.1.2/24' and is assigned
to the first VM provider, usually VirtualBox. New pools are created for other
providers by incrementing the second octet to create a new '/24'.
To change the starting range, add the following to a Vagrantfile _before_ the
Vagrant configuration block:

    AutoNetwork.default_pool = '172.16.0.0/24'

A '/24' should always be used as the default pool in order for multiple
providers to be supported correctly. If VMs that use `auto_network` assigned IP
addresses have already been created, then the AutoNetwork pool file will have
to be cleared:

    ~/.vagrant.d/auto_network/pool.yaml

Running `vagrant reload` on existing VMs will assign new IP addresses from the
newly configured IP range.

The AutoNetwork pool is currently shared across all Vagrant environments which
means it is not possible to configure a separate range per-Vagrantfile.


Contact
-------

  * [Source code](https://github.com/adrienthebo/vagrant-auto_network)
  * [Issue tracker](https://github.com/adrienthebo/vagrant-auto_network/issues)

If you have questions or concerns about this module, contact finch on Freenode,
or email adrien@puppetlabs.com.
