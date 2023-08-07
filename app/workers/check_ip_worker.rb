# frozen_string_literal: true

class CheckIpWorker
  include Sidekiq::Worker

  def perform
    ips_list = Services::Scanner.run
    return if ips_list.empty?

    logger.info("Found ips: - #{ips_list}")
    ips_list.each do |ip|
      logger.info("#{ip} - record created") if Models::Machine.create_redis_record(ip)
    end
  end
end
