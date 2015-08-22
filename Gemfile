source 'https://rubygems.org'
ruby '2.0.0'

ENV['TEST_VAGRANT_VERSION'] ||= 'v1.7.4'

# Using the :plugins group causes Vagrant to automagially load auto_network
# during acceptance tests.
group :plugins do
  gemspec
end

group :test do
  if ENV['TEST_VAGRANT_VERSION'] == 'HEAD'
    gem 'vagrant', :github => 'mitchellh/vagrant', :branch => 'master'
  else
    gem 'vagrant', :github => 'mitchellh/vagrant', :tag => ENV['TEST_VAGRANT_VERSION']
  end

  # Pinned on 12/10/2014. Compatible with Vagrant 1.5.x, 1.6.x and 1.7.x.
  gem 'vagrant-spec', :github => 'mitchellh/vagrant-spec', :ref => '1df5a3a'
end

eval_gemfile "#{__FILE__}.local" if File.exists? "#{__FILE__}.local"
