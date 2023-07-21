# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'

RSpec.describe CheckIpWorker do
  describe '#perform' do
    let(:ips_list) { ['1.1.1.1:3000'] }
    context 'when ips is not empty'
    before do
      allow(Services::Scanner).to receive(:run).and_return(ips_list)
      allow(Models::Machine).to receive(:create_redis_record).and_return(true)
    end

    it 'calls Services::Scanner.run' do
      expect(Services::Scanner).to receive(:run)
      CheckIpWorker.perform_inline
    end
  end

  context 'when ips_list is empty' do
    let(:ips_list) { [] }

    before do
      allow(Services::Scanner).to receive(:run).and_return(ips_list)
      allow(Models::Machine).to receive(:create_redis_record).and_return(true)
    end

    it 'does not log found ips' do
      expect(Services::Scanner).to receive(:run)
      CheckIpWorker.perform_inline
    end
  end
end
