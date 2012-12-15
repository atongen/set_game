require 'connection_pool'
require 'redis'
require 'redis/namespace'
require 'redis/objects'

module SetGame
  class RedisConnection
    def self.create(options = {})
      options = {} unless options.present?
      if %w{ host port database }.all? { |key| options[key].present? }
        url = "redis://#{options['host']}:#{options['port']}/#{options['database']}"
      else
        url = 'redis://localhost:6379/0'
      end
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
