bind_address = ENV.fetch('BIND_ADDR', '0.0.0.0')
bind_port = ENV.fetch('BIND_PORT', '3000')
bind "tcp://#{bind_address}:#{bind_port}"

max_threads = Integer(ENV.fetch('MAX_THREADS', 2))
min_threads = Integer(ENV.fetch('MIN_THREADS', 2))
threads min_threads, max_threads

# Use multiple workers when requested and supported by the runtime.
num_workers = Integer(ENV.fetch('WORKERS', 1))
if num_workers > 1 && RUBY_ENGINE != 'jruby'
  workers num_workers

  # Combine Ruby 2.0.0dev or REE with "preload_app!" for memory savings
  preload_app!

  on_worker_boot do
    # Open the DB connections in the worker process.
    defined?(ActiveRecord::Base) and
      ActiveRecord::Base.establish_connection
  end
end
