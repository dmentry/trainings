module IpFinderHelper
  require 'uri'
  require 'net/http'
  require 'json'

  def self.ip_address(ip)
    uri = URI("http://ip-api.com/json/#{ip}?fields=country,regionName,city,zip,lat,lon,isp")

    res = Net::HTTP.get_response(uri)

    JSON.parse(res.body, symbolize_names: true)
  end
end