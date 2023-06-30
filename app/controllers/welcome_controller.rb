# frozen_string_literal: true

class WelcomeController < ApplicationController
  before_action :take_ips

  def index
    @ips
  end

  def check
    jid = CheckIpWorker.perform_async
    Rails.logger.info("CheckIpWorker started with jid = #{jid}")
  end

  def info
    @ip = @ips[params[:id].to_i]
    @machine_info = MachineInfo.show_info(@ip)
  end

  def stop
    change_with_flash('enabled')
  end

  def start
    change_with_flash('disabled')
  end

  private

  def take_ips
    redis = Redis.new
    @ips = redis.get('ips')&.split("\n")
  end

  def change_with_flash(state)
    response = StateChanger.change(params[:ip], state)
    if response.code == '200'
      redirect_with_notice(info_path(@ips.index(params[:ip])), 'State changed successfully')
    else
      redirect_with_alert(root_path, 'Failed to change state')
    end
  end
end
