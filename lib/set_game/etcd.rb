require 'yaml'
require 'etcd'
require 'openssl'
require 'thread'

module SetGame
  module Etcd

    @@mutex = Mutex.new

    def self.config_valid?
      %w{
        ETCD_KEY
        ETCD_HOST
        ETCD_PORT
        RACK_ENV
      }.all? { |key| ENV[key] }
    end

    def self.read
      vars.each do |var|
        path = "/_#{ENV['ETCD_KEY']}/#{ENV['RACK_ENV']}/#{var.downcase}"
        begin
          value = client.get(path).value
        rescue ::Etcd::KeyNotFound
          puts "etcd key for #{var} not found"
        else
          ENV[var] = value
        end
      end
    end

    def self.write
      vars.each do |var|
        if !ENV[var]
          puts "not writing empty key #{var}"
          next
        end

        path = "/_#{ENV['ETCD_KEY']}/#{ENV['RACK_ENV']}/#{var.downcase}"
        client.set(path, value: ENV[var])
        puts "wrote key #{var}"
      end
    end

    def self.vars
      YAML.load(File.read(SET_GAME_ROOT.join('config/application.yml.dist')))[ENV['RACK_ENV']].keys
    end

    def self.client
      @@mutex.synchronize do
        @client ||= ::Etcd.client(opts)
      end
    end

    def self.opts
      opts = {
        host: ENV['ETCD_HOST'],
        port: ENV['ETCD_PORT']
      }

      if %w{
        ETCD_CA_FILE
        ETCD_SSL_CERT
        ETCD_SSL_KEY
      }.all? { |key| ENV[key] }
        opts[:use_ssl] = true
        opts[:ca_file] = ENV['ETCD_CA_FILE']
        opts[:ssl_cert] = OpenSSL::X509::Certificate.new(File.read(ENV['ETCD_SSL_CERT']))
        opts[:ssl_key] = OpenSSL::PKey::RSA.new(File.read(ENV['ETCD_SSL_KEY']))
      end

      opts
    end

  end
end
