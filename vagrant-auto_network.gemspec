lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'auto_network/version'

Gem::Specification.new do |gem|
  gem.name        = "vagrant-auto_network"
  gem.version     = AutoNetwork::VERSION

  gem.authors  = 'Adrien Thebo'
  gem.email    = 'adrien@somethingsinistral.net'
  gem.homepage = 'https://github.com/adrienthebo/vagrant-auto_network'

  gem.summary     = "Automatically create an internal network for all vagrant boxes"

  gem.files        = %x{git ls-files -z}.split("\0")
  gem.require_path = 'lib'
end
