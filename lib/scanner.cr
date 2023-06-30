require "http/client"
require "json"
require "option_parser"

command = `arp-scan --interface=enp0s3 --localnet`
ips = command.scan(/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/).map { |md| md[0]? }.compact

option_parser = OptionParser.parse do |parser|
  parser.banner = "This script checks valid ports on your network"
  parser.on "-p PORTS", "--ports PORTS,etc", "Check ports of machines. Example: -p 80,443,8080" do |ports|
    check_connect(ips,ports)
    exit
  end
  parser.on "-h", "--help", "Show help" do
    puts parser
    exit
  end
end

check_connect(ips)

def check_port(ip,port)
  valid_keys = ["type", "state", "serial_number", "location"]
  begin
    client = HTTP::Client.new(ip,port)
    client.connect_timeout = 0.02
    client.read_timeout = 0.02
    response = client.get("/api/info")
      if response.status_code == 200 && response.headers["content-type"] == "application/json" && JSON.parse(response.body).as_h.keys == valid_keys
        puts "#{ip}:#{port}"
      end
    client.close
  rescue e
  end
end

def check_connect(ips, ports = [1000,10000])
  ips.each do |ip|
    if ports.is_a?(Array)
      (ports.first..ports.last).each { |port| check_port(ip, port) }
    else
      ports.split(',').each { |port| check_port(ip, port.to_i) }
    end
  end
end
