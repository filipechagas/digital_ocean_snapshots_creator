require "json"
require 'net/http'
require 'uri'

class IpRetriever
  attr_reader :ip_list

  def initialize
    @ip_list = []
    retrieve_ips_list
  end

  private
  def ignore_names_prefixes
    %w(Forza-centos-8gb-nyc2-01 c66-)
  end

  def is_in_ignore_list?(droplet_name)
    ignore_names_prefixes.any?{|prefix| droplet_name =~ /\A#{prefix}/ }
  end

  def retrieve_ips_list
    uri = URI.parse("https://api.digitalocean.com/v2/droplets?page=1&per_page=50")
    request = Net::HTTP::Get.new(uri)
    request.content_type = "application/json"
    request["Authorization"] = "Bearer #{ ENV['DO_AUTHORIZATION'] }"

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request(request)
    end

    result = JSON.parse(response.body)

    Array( result['droplets'] ).each do |droplet|
      unless is_in_ignore_list? droplet['name']
        @ip_list << droplet['networks']['v4'][0]['ip_address']
      end
    end
  end
end
