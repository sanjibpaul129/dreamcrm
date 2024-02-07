PumaWorkerKiller.config do |config|
  config.ram           = 1024 # mb
  config.frequency     = 20    # seconds
  config.percent_usage = 0.98
  config.rolling_restart_frequency = 1 * 3600 # 12 hours in seconds
end
PumaWorkerKiller.start