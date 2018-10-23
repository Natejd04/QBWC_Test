require File.expand_path('../boot', __FILE__)

require 'csv'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)





module Qbwc3
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.action_dispatch.default_headers = {
    'Access-Control-Allow-Origin' => 'https://zingbars.com',
    'Access-Control-Request-Method' => %w{POST OPTIONS}.join(","),
    'Access-Ctonrol-Max-Age' => '1000',
    'Access-Control-Allow-Headers' => 'Origin, X-Requested-With, Content-Type, Accept',
  }

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.assets.paths << Rails.root.join("app", "assets", "fonts")
    # config.assets.paths << "#{Rails.root}/app/assets/stylesheets/bootstrap/" 
    # config.assets.paths << "#{Rails.root}/vendor/assets/fonts"
    
    config.active_record.raise_in_transactional_callbacks = true
    config.autoload_paths += Dir["#{config.root}/lib/**/"]
    config.time_zone = 'Pacific Time (US & Canada)'
    config.before_configuration do
        env_file = File.join(Rails.root, 'config', 'local_env.yml')
        YAML.load(File.open(env_file)).each do |key, value|
            ENV[key.to_s] = value
        end if File.exists?(env_file)
    end
  end
end
