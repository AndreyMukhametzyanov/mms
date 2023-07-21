# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'

RSpec.describe Models::Machine do
  describe '.create_redis_record' do
    let(:ip) { '127.0.0.1' }
    let(:serial_number) { '123456789' }
    let(:short_info) { { 'serial_number' => serial_number } }
    let!(:redis) { Redis.new(Settings.model_repository.redis.to_h) }

    before do
      stub_request(:get, "http://#{ip}/api/info").to_return(status: 200, body: short_info.to_json,
                                                            headers: { 'Content-Type' => 'application/json' })
    end

    it 'creates a redis record for the machine' do
      Models::Machine.create_redis_record(ip)
      puts '*******'
      puts redis.keys("*").inspect
    end
  end
end
