# frozen_string_literal: true

class StateChanger
  def self.change(ip, state)
    url = URI.parse("http://#{ip}/api/change_state")
    http = Net::HTTP.new(url.host, url.port)

    request = Net::HTTP::Post.new(url.path, { 'Content-Type' => 'application/json' })
    request.body = (state == 'enabled' ? { state: 'disabled' }.to_json : { state: 'enabled' }.to_json)

    http.request(request)
  end
end
