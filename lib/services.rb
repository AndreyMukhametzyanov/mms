# frozen_string_literal: true

require 'benchmark'

module Services
  class Scanner
    CONCURRENCY        = 4
    PATH_TO_EXECUTABLE = Rails.root.join('lib', 'assets')
    EXECUTABLE_NAME    = 'scanner'
    START_PORT_FLAG    = '--start_port=%d'
    END_PORT_FLAG      = '--end_port=%d'
    START_PORT         = 2000
    END_PORT           = 5000

    attr_reader :concurrency, :start_port, :end_port, :logger

    def self.run(concurrency: nil, start_port: nil, end_port: nil, logger: nil)
      new(concurrency, start_port, end_port, logger).run_concurrently
    end

    def initialize(concurrency = nil, start_port = nil, end_port = nil, logger = nil)
      @concurrency = concurrency || CONCURRENCY
      @start_port  = start_port  || START_PORT
      @end_port    = end_port    || END_PORT
      @logger      = logger      || Rails.logger
    end

    def run_concurrently
      threads = split_ports_range.map do |part_of_ports_range|
        Thread.new { scanner_command(part_of_ports_range) }
      end

      with_time_measure { threads.each(&:join) }
      threads.map { |thread| thread.value.split("\n") }.flatten
    end

    private

    def ports_range
      @ports_range ||= start_port..end_port
    end

    def scanner_command(part_of_ports_range)
      full_path       = "#{PATH_TO_EXECUTABLE}/#{EXECUTABLE_NAME}"
      start_port_flag = (START_PORT_FLAG % part_of_ports_range.first).to_s
      end_port_flag   = (END_PORT_FLAG % part_of_ports_range.last).to_s

      `#{full_path} #{start_port_flag} #{end_port_flag}`
    end

    def split_ports_range
      chunk_size = (ports_range.size.to_f / concurrency).ceil
      ports_range.each_slice(chunk_size).map { |chunk| chunk.first..chunk.last }
    end

    def with_time_measure(&block)
      log('Execution started')
      benchmark = Benchmark.measure(&block)
      log("Real execution time: #{benchmark.real.round(2)}s")
    end

    def log(message)
      logger.info("[Scanner] #{message}")
    end
  end
end
