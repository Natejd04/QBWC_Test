workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['RAILS_MAX_THREADS'] || 5)
threads threads_count, threads_count

app_dir = File.expand_path("../..", __FILE__)
shared_dir = "#{app_dir}/shared"

# Default to production
rails_env = ENV['RAILS_ENV'] || "production"
environment rails_env


# Let's run this covertly
daemonize false

# We need to bind our certs, and the operation has to happen before preload
bind 'ssl://0.0.0.0:3000?key=.ssl/importly.key&cert=.ssl/importly_app.crt&verify_mode=none&ca=.ssl/importly_app.ca-bundle'


##preload_app!

##rackup      DefaultRackup
#port        ENV['PORT']     || 3000
##environment ENV['RACK_ENV'] || 'production'

#ssl_bind '0.0.0.0', '9292', {
#   key: '.ssl/importly.key',
#   cert: '.ssl/importly_app.crt',
#   ca: '.ssl/importly_app.ca-bundle'
#}

# Logging
#stdout_redirect "#{shared_dir}/log/puma.stdout.log", "#{shared_dir}/log/puma.stderr.log", true

# Set master PID and state locations
pidfile "#{shared_dir}/pids/puma.pid"
state_path "#{shared_dir}/pids/puma.state"
activate_control_app

on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
require "active_record"
  ActiveRecord::Base.connection.disconnect! rescue ActiveRecord::ConnectionNotEstablished
  ActiveRecord::Base.establish_connection(YAML.load_file("#{app_dir}/config/database.yml")[rails_env])
end
