source 'https://rubygems.org'
ruby '2.0.0'

gemspec

group :development do
  gem 'vagrant', :github => 'mitchellh/vagrant', :tag => 'v1.5.4'
  # Pinned on 05/05/2014.
  gem 'vagrant-spec', :github => 'mitchellh/vagrant-spec', :ref => 'aae28ee'
  gem 'rake'
end

if File.exists? "#{__FILE__}.local"
  eval(File.read("#{__FILE__}.local"), binding)
end
