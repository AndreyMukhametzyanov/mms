# frozen_string_literal: true

class DataMachinesController < ApplicationController

  def index; end
  
  def check_ip
    @active_ip = CheckIpJob.perform_async
    redirect_to root
  end
end
