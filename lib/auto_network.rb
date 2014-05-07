module AutoNetwork

  require 'auto_network/settings'
  extend Settings

  require 'auto_network/action'
  require 'auto_network/plugin'
  require 'auto_network/version'
  require 'auto_network/pool_manager'
end

I18n.load_path << File.expand_path('../templates/locales/en.yml', File.dirname(__FILE__))
