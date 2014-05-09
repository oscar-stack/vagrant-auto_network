Vagrant Auto-network
====================

Automatically configure Vagrant private network interfaces.

[![Build Status](https://travis-ci.org/adrienthebo/vagrant-auto_network.svg?branch=travis-ci)](https://travis-ci.org/adrienthebo/vagrant-auto_network)

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

Usage
-----

    Vagrant.configure('2') do |config|
      config.vm.define 'first' do |node|
        node.vm.box = "centos-5-i386"

        node.vm.network :private_network, :auto_network => true
      end

      config.vm.define 'second' do |node|
        node.vm.box = "centos-5-i386"

        node.vm.network :private_network, :auto_network => true
      end
    end

Installation
------------

    vagrant plugin install vagrant-auto_network

Caveats
-------

The default pool range has been hardcoded as '10.20.1.2/24', pending the
ability to query the host virtual network adapters for their configuration.
To change this, add the following _before_ the Vagrant configuration block:

    AutoNetwork.default_pool = '172.16.0.0/24'

Contact
-------

  * [Source code](https://github.com/adrienthebo/vagrant-auto_network)
  * [Issue tracker](https://github.com/adrienthebo/vagrant-auto_network/issues)

If you have questions or concerns about this module, contact finch on Freenode,
or email adrien@puppetlabs.com.
