# frozen_string_literal: true

class CheckIpWorker
  include Sidekiq::Worker

  def perform(_ports = '')
    logger.info 'Starting ip cheking'
    ips = `./lib/scanner -- p 3030`
    redis = Redis.new
    redis.set('ips', ips)
    ips.split("\n").each do |ip|
      MachineInfo.show_info(ip)
    end
    logger.info 'Done'
  end
end
