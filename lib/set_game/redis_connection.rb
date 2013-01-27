require 'connection_pool'
require 'redis'
require 'redis/namespace'
require 'redis/objects'

module SetGame
  class RedisConnection
    def self.create(options = {})
      options = {} unless options.present?
      options['host'] = 'localhost' unless options['host']
      options['port'] = 6379 unless options['port']
      options['database'] = 0 unless options['database']
      url = "redis://#{options['host']}:#{options['port']}/#{options['database']}"

      driver = options['driver'] || 'ruby'
      # need a connection for Fetcher and Retry
      size = options[:size] || 4

      ConnectionPool.new(:timeout => 1, :size => size) do
        build_client(url, options['namespace'], driver)
      end
    end

    def self.build_client(url, namespace, driver)
      client = Redis.connect(:url => url, :driver => driver)
      if namespace
        Redis::Namespace.new(namespace, :redis => client)
      else
        client
      end
    end
    private_class_method :build_client
  end
end
