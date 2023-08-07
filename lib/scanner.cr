require "http/client"
require "json"
require "option_parser"

command = `arp-scan --interface=enp0s3 --localnet`
ips_list = command.scan(/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/).map { |md| md[0]? }.compact
#*****
ips_list << "127.0.0.2"
ips_list << "127.0.0.3"

ping_endpoint      = "/api/info"
response_json_keys = ["type", "state", "serial_number", "location"]

default_start_port = 2990
default_end_port   = 3010
processing_ports   = [] of Int32

option_parser = OptionParser.parse do |parser|
  parser.banner = "This script checks valid ports on your network"

  parser.on "-p PORTS", "--ports=PORTS", "Check ports of machines. Example: -p 80,443,8080 or --ports=4340,5430,5444" do |ports|
    processing_ports = ports.split(',').map { |port| port.to_i }
  end

  parser.on "-s START_PORT", "--start_port=START_PORT", "Start port. Example: -sp 2000 or --start_port=2000" do |start_port|
    default_start_port = start_port.to_i
  end

  parser.on "-e END_PORT", "--end_port=END_PORT", "End port. Example: -ep 4000 or --end_port=6000" do |end_port|
    default_end_port = end_port.to_i
  end

  parser.on "-h", "--help", "Show help" do
    puts parser
    exit
  end
end

exit if ips_list.empty?
processing_ports = (default_start_port..default_end_port).to_a if processing_ports.empty?

def valid_response?(response, response_json_keys)
  response.status_code == 200 && response.headers["content-type"] == "application/json" && JSON.parse(response.body).as_h.keys == response_json_keys
end

ips_list.each do |ip|
  processing_ports.each do |port|
    client = HTTP::Client.new(ip, port)

    client.connect_timeout = 0.05
    client.read_timeout    = 0.05

    response = client.get(ping_endpoint)
    puts "#{ip}:#{port}" if valid_response?(response, response_json_keys)

    client.close
    break
  rescue Socket::ConnectError
    # relax
  rescue
    # take it easy
  end
end
