# frozen_string_literal: true

class MachineController < ApplicationController
  def index
    @all_machines = Models::Machine.all
  end

  def check
    jid = CheckIpWorker.perform_async
    Rails.logger.info("CheckIpWorker started with jid = #{jid}")
    redirect_with_notice(root_path, 'Идет сканирование')
  end

  def info
    machine = Models::Machine.find_by_sn(params[:sn])
    if machine.nil?
      redirect_with_alert(root_path, 'Станок не найден')
    else
      @machine_info = machine&.full_info
    end
  end

  def change_state
    machine = Models::Machine.find_by_sn(params[:sn])
    if machine.nil?
      redirect_with_alert(info_path(params[:sn]), 'Отсутствует соединине со станком')
    else
      machine.change_state(params[:state])
      redirect_with_notice(info_path(params[:sn]), 'Состояние изменено')
    end
  end
end
