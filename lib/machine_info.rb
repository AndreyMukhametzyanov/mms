# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

class MachineInfo
  def self.show_info(ip)
    url = "http://#{ip}/api/info"
    machine_uri = URI.parse(url)
    response = Net::HTTP.get_response(machine_uri)
    JSON.parse(response.body)
  end
end
