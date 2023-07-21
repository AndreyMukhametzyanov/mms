# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'

RSpec.describe MachineController do
  let!(:redis) { Redis.new(Settings.model_repository.redis.to_h) }
  let(:fake_machine) { instance_double(Models::Machine) }

  describe '#index' do
    before do
      allow(Models::Machine).to receive(:all).and_return([fake_machine])
      get :index
    end

    it 'return correct render for index' do
      expect(Models::Machine).to have_received(:all)
      expect(response).to have_http_status(:ok)
      expect(assigns(:all_machines)).to match_array(fake_machine)
      expect(response).to render_template('index')
    end
  end

  describe '#info' do
    let(:sn) { { serial_number: '11' } }

    context 'when machine was not find' do
      let(:alert_message) { 'Станок не найден' }

      before do
        get :info, params: { sn: '22' }
      end

      it 'return correct render for info' do
        expect(flash[:alert]).to eq(alert_message)
        expect(response).to redirect_to root_path
      end
    end

    context 'when machine was find' do
      before do
        allow(Models::Machine).to receive(:find_by_sn).with(sn[:serial_number]).and_return(fake_machine)
        allow(fake_machine).to receive(:full_info).and_return(sn)

        get :info, params: { sn: sn[:serial_number] }
      end

      it 'return correct render for info' do
        expect(Models::Machine).to have_received(:find_by_sn).with(sn[:serial_number])
        expect(response).to have_http_status(:ok)
        expect(assigns(:machine_info)).to eq(sn)
        expect(response).to render_template('info')
      end
    end
  end

  describe '#check' do
    let(:fake_ips) { ['1.1.1.1:3000', '2.2.2.2:3000'] }
    let(:notice_message) { 'Идет сканирование' }

    before do
      allow(CheckIpWorker).to receive(:perform_async).and_return(fake_ips)
      post :check
    end

    it 'return ips with notice' do
      expect(CheckIpWorker).to have_received(:perform_async)
      expect(flash[:notice]).to eq(notice_message)
      expect(response).to redirect_to root_path
    end
  end

  describe '#change_state' do
    let(:sn) { { serial_number: '11' } }
    let(:state) { 'enabled' }

    context 'when machine was not find' do
      let(:alert_message) { 'Отсутствует соединине со станком' }

      before do
        allow(Models::Machine).to receive(:find_by_sn).with(sn[:serial_number]).and_return(nil)
        post :change_state, params: { sn: '11', state: }
      end

      it 'change state of machine' do
        expect(flash[:alert]).to eq(alert_message)
        expect(response).to redirect_to info_path(sn[:serial_number])
      end
    end

    context 'when machine was find' do
      let(:notice_message) { 'Состояние изменено' }

      before do
        allow(Models::Machine).to receive(:find_by_sn).with(sn[:serial_number]).and_return(fake_machine)
        allow(fake_machine).to receive(:change_state).with(state).and_return(true)
        post :change_state, params: { sn: sn[:serial_number], state: }
      end

      it 'return notice and redirect to info' do
        expect(Models::Machine).to have_received(:find_by_sn).with(sn[:serial_number])
        expect(fake_machine).to have_received(:change_state).with(state)
        expect(response).to redirect_to info_path(sn[:serial_number])
        expect(flash[:notice]).to eq(notice_message)
      end
    end
  end
end
