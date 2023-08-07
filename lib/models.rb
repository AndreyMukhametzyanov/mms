# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

module Models
  class Machine
    SHORT_INFO_PATH   = 'api/info'
    FULL_INFO_PATH    = 'api/full_metrics'
    CHANGE_STATE_PATH = 'api/change_state'
    REDIS_KEY_PREFIX  = 'machine:%s'

    NotResponded = Class.new(StandardError)

    class << self
      def create_redis_record(ip)
        url = "http://#{ip}/#{SHORT_INFO_PATH}"
        response = Net::HTTP.get_response(URI.parse(url))
        info = JSON.parse(response.body)
        redis.set(REDIS_KEY_PREFIX % info['serial_number'], ip)
        true
      rescue NotResponded
        false
      end

      def find_by_sn(number)
        return unless (ip = redis.get(REDIS_KEY_PREFIX % number))

        new(ip)
      end

      def all
        redis.keys(REDIS_KEY_PREFIX % '*').map do |machine|
          new(redis.get(machine))
        rescue NotResponded
          next
        end
      end

      private

      def redis
        @redis ||= Redis.new(Settings.model_repository.redis.to_h)
      end
    end

    attr_accessor :ip, :serial_number

    def initialize(ip)
      @ip = ip
      @serial_number = short_info.try(:[], 'serial_number')
    end

    def short_info
      url = "http://#{ip}/#{SHORT_INFO_PATH}"
      machine_uri = URI.parse(url)
      response = Net::HTTP.get_response(machine_uri)
      JSON.parse(response.body)
    rescue Errno::ECONNREFUSED
      nil
    end

    def full_info
      url = "http://#{ip}/#{FULL_INFO_PATH}"
      machine_uri = URI.parse(url)
      response = Net::HTTP.get_response(machine_uri)
      JSON.parse(response.body)
    rescue Errno::ECONNREFUSED
      nil
    end

    def change_state(current_state)
      url = URI.parse("http://#{@ip}/#{CHANGE_STATE_PATH}")
      http = Net::HTTP.new(url.host, url.port)
      request = Net::HTTP::Post.new(url.path, { 'Content-Type' => 'application/json' })
      request.body = (current_state == 'enabled' ? { state: 'disabled' }.to_json : { state: 'enabled' }.to_json)
      http.request(request)
    end
  end
end
