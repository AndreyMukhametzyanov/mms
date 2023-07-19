# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'

RSpec.describe MachineController do
  let!(:redis) { Redis.new(Settings.model_repository.redis.to_h) }
  let(:fake_machine) { instance_double(Models::Machine) }

  describe '#index' do
    before do
      # allow(fake_machine).to receive(:short_info).and_return({a: 1})
      # allow(fake_machine).to receive(:change_state).with('enabled').and_return(true)
      allow(Models::Machine).to receive(:all).and_return([fake_machine])
      # allow(Models::Machine).to receive(:find_by_sn).and_return(fake_machine)
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
      let(:sn) { { serial_number: '11' } }
      let(:alert_message) { 'Станок не найден' }

      before do
        allow(Models::Machine).to receive(:find_by_sn).and_return(fake_machine)
        allow(fake_machine).to receive(:full_info).and_return(sn)
    
        get :info, params: { sn: '22' }
      end

      it 'return correct render for info' do
        # expect(flash[:alert]).to eq(alert_message)
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

end
