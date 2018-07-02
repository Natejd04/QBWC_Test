workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['RAILS_MAX_THREADS'] || 5)
threads threads_count, threads_count

# Let's run this covertly
daemonize false

# We need to bind our certs, and the operation has to happen before preload
bind 'ssl://0.0.0.0:3000?key=.ssl/importly.key&cert=.ssl/importly_app.crt&verify_mode=none&ca=.ssl/importly_app.ca-bundle'

preload_app!

rackup      DefaultRackup
#port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'production'

#ssl_bind '0.0.0.0', '9292', {
#   key: '.ssl/importly.key',
#   cert: '.ssl/importly_app.crt',
#   ca: '.ssl/importly_app.ca-bundle'
#}

on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  ActiveRecord::Base.establish_connection
end
