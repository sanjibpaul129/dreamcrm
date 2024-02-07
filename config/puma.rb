# workers Integer(ENV['WEB_CONCURRENCY'] || 2)
# threads_count = Integer(ENV['MAX_THREADS'] || 5)
# threads threads_count, threads_count

# preload_app!

# # rackup      DefaultRackup
# port        ENV['PORT']     || 3000
# environment ENV['RACK_ENV'] || 'development'

# on_worker_boot do
#   # Worker specific setup for Rails 4.1+
#   # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
#   ActiveRecord::Base.establish_connection
# end

# Determine the number of workers
workers_count = Integer(ENV['WEB_CONCURRENCY'] || 0)
workers workers_count

# Thread configuration
threads_count = Integer(ENV['MAX_THREADS'] || 5)
threads threads_count, threads_count

# Basic settings: environment, port, etc.
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

# Conditional worker-specific setup
if workers_count > 0
  on_worker_boot do
    # Worker specific setup for Rails 4.1+
    ActiveRecord::Base.establish_connection
  end

  before_fork do
    ActiveRecord::Base.connection_pool.disconnect! if defined?(ActiveRecord)
  end
end
