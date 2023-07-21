# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'

RSpec.describe Models::Machine do
  let(:ip) { '127.0.0.1' }
  let(:serial_number) { '123456789' }
  let(:short_info) { { 'serial_number' => serial_number } }
  let!(:redis) { Redis.new(Settings.model_repository.redis.to_h) }
  let(:prefix) { 'machine:%s' }
  let(:url) { "http://#{ip}/api/info" }

  describe '.create_redis_record' do
    context 'when ip of machine is valid' do
      let(:ip) { '127.0.0.1' }

      before do
        stub_request(:get, url).to_return(status: 200, body: short_info.to_json,
                                          headers: { 'Content-Type' => 'application/json' })
      end

      it 'creates a redis record for the machine' do
        Models::Machine.create_redis_record(ip)
        machine = redis.keys(prefix % serial_number)
        expect(redis.keys(prefix % serial_number)).to match_array([prefix % serial_number])
        expect(redis.get(machine)).to eq(ip)
      end
    end

    context 'when ip of machine is not valid' do
      before do
        stub_request(:get, url).and_raise(Models::Machine::NotResponded)
      end

      it 'not creates a redis record for the machine and return false' do
        expect(Models::Machine.create_redis_record(ip)).to be_falsy
      end
    end
  end

  describe '.find_by_sn' do
    context 'when the machine exist in redis' do
      before do
        stub_request(:get, url).to_return(status: 200, body: short_info.to_json,
                                          headers: { 'Content-Type' => 'application/json' })
        redis.set(prefix % serial_number, ip)
      end

      it 'returns a Machine instance with the given serial number' do
        machine = Models::Machine.find_by_sn(serial_number)
        expect(machine.ip).to eq(ip)
        expect(machine.serial_number).to eq(serial_number)
      end
    end

    context 'when the machine does not exist in redis' do
      it 'returns nil' do
        expect(Models::Machine.find_by_sn(serial_number)).to be_nil
      end
    end
  end

  describe '.all' do
    let(:new_ip) { '192.168.0.1' }
    let(:new_serial_number) { '987654321' }
    let(:new_url) { "http://#{new_ip}/api/info" }
    let(:new_short_info) { { 'serial_number' => new_serial_number } }

    before do
      stub_request(:get, url).to_return(status: 200, body: short_info.to_json,
                                        headers: { 'Content-Type' => 'application/json' })
      redis.set(prefix % serial_number, ip)

      stub_request(:get, new_url).to_return(status: 200, body: new_short_info.to_json,
                                            headers: { 'Content-Type' => 'application/json' })
      redis.set(prefix % new_serial_number, new_ip)
    end

    it 'returns an array of Machine instances' do
      machines = Models::Machine.all
      expect(machines.size).to eq(2)
      expect(machines[0].ip).to eq(new_ip)
      expect(machines[0].serial_number).to eq(new_serial_number)
      expect(machines[1].ip).to eq(ip)
      expect(machines[1].serial_number).to eq(serial_number)
    end
  end

  describe '.short_info' do
    context 'when the machine responded' do
      before do
        stub_request(:get, url).to_return(status: 200, body: short_info.to_json,
                                          headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns the short info of the machine' do
        machine = Models::Machine.new(ip)
        expect(machine.short_info).to eq(short_info)
      end
    end

    context 'when the machine does not respond' do
      before do
        stub_request(:get, url).and_raise(Errno::ECONNREFUSED)
      end

      it 'returns nil' do
        machine = Models::Machine.new(ip)
        expect(machine.short_info).to be_nil
      end
    end
  end

  describe '.full_info' do
    let(:new_url) { "http://#{ip}/api/full_metrics" }
    let(:full_info) { { 'speed' => 50 } }

    context 'when the machine responded' do
      before do
        stub_request(:get, url).to_return(status: 200, body: short_info.to_json,
                                          headers: { 'Content-Type' => 'application/json' })
        stub_request(:get, new_url).to_return(status: 200, body: full_info.to_json,
                                              headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns the full info of the machine' do
        machine = Models::Machine.new(ip)
        expect(machine.full_info).to eq(full_info)
      end
    end

    context 'when the machine does not respond' do
      before do
        stub_request(:get, url).and_raise(Errno::ECONNREFUSED)
        stub_request(:get, new_url).and_raise(Errno::ECONNREFUSED)
      end

      it 'returns nil' do
        machine = Models::Machine.new(ip)
        expect(machine.full_info).to be_nil
      end
    end
  end

  #todo
  describe '.change_state' do
    let(:current_state) { 'enabled' }
    let(:new_state) { { state: 'disabled' }.to_json }
    let(:body) { current_state == 'enabled' ? { state: 'disabled' }.to_json : { state: 'enabled' }.to_json }
    let(:change_url) { "http://#{ip}/api/change_state" }
    let(:short_info) { { 'serial_number' => serial_number, 'state' => 'enabled' } }

    before do
      stub_request(:get, url).to_return(status: 200, body: short_info.to_json,
                                        headers: { 'Content-Type' => 'application/json' } )
      stub_request(:post, change_url).to_return(body: body)
    end

    it 'sends a POST request to change the state of the machine' do
      machine = described_class.new(ip)
      puts machine.short_info
      machine.change_state(current_state)
      puts machine.short_info
    end

    context 'when machine does not respond' do
      before do
        stub_request(:post, change_url).with(body: body).to_raise(StandardError)
      end

      it 'raises a Models::Machine::NotResponded error' do
        expect { change_state(current_state) }.to raise_error(StandardError)
      end
    end
  end
  end
end
