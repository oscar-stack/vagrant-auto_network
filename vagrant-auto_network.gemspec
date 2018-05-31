lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'auto_network/version'

Gem::Specification.new do |gem|
  gem.name        = "vagrant-auto_network"
  gem.version     = AutoNetwork::VERSION

  gem.authors  = ['Adrien Thebo', 'Charlie Sharpsteen']
  gem.email    = ['adrien@somethingsinistral.net', 'source@sharpsteen.net']
  gem.homepage = 'https://github.com/adrienthebo/vagrant-auto_network'

  gem.summary     = "Automatically create an internal network for all vagrant boxes"

  gem.files        = %x{git ls-files -z}.split("\0")
  gem.require_path = 'lib'

  gem.license = 'Apache 2.0'

  gem.add_development_dependency 'rake'
end
