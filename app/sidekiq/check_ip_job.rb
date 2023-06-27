class CheckIpJob
  include Sidekiq::Job

  def perform
    `./lib/scanner`
  end
end
