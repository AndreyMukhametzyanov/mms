# frozen_string_literal: true

class MachineController < ApplicationController
  def index
    @all_machines = Models::Machine.all
  end

  def check
    jid = CheckIpWorker.perform_async
    Rails.logger.info("CheckIpWorker started with jid = #{jid}")
    redirect_with_notice(root_path, 'Scan completed')
  end

  def info
    @machine_info = Models::Machine.find_by_sn(params[:sn])&.full_info
  end

  def change_state
    machine = Models::Machine.find_by_sn(params[:sn])
    return unless machine.change_state(machine.short_info['state'])

    redirect_with_notice(info_path(params[:sn]), 'State changed successfully')
  end
end
