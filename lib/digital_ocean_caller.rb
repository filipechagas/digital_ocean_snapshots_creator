require "json"
require 'net/http'
require 'uri'

class DigitalOceanCaller
  def power_off_by_tag(tag)
    uri = URI.parse("https://api.digitalocean.com/v2/droplets/actions?tag_name=#{ tag_name }")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    request["Authorization"] = "Bearer #{ ENV['DO_AUTHORIZATION'] }"
    request.body = JSON.dump({
      "type" => "power_off"
    })

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request(request)
    end

    response.body
  end

  def tag_droplet_for_snapshot(droplet_id)
    uri = URI.parse("https://api.digitalocean.com/v2/tags/snapshot_backup/resources")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    request["Authorization"] = "Bearer #{ ENV['DO_AUTHORIZATION'] }"
    request.body = JSON.dump({
      "resources" => [
        { "resource_id" => droplet_id, "resource_type" => "droplet" }
      ]
    })

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request(request)
    end

    response.body
  end

  def power_droplet_off(droplet_id)
    uri = URI.parse("https://api.digitalocean.com/v2/droplets/#{droplet_id}/actions")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    request["Authorization"] = "Bearer #{ ENV['DO_AUTHORIZATION'] }"
    request.body = JSON.dump({
      "type" => "power_off"
    })

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request(request)
    end

    response.body
  end

  def all_droplets
    uri = URI.parse("https://api.digitalocean.com/v2/droplets?per_page=100")
    request = Net::HTTP::Get.new(uri)
    request.content_type = "application/json"
    request["Authorization"] = "Bearer #{ ENV['DO_AUTHORIZATION'] }"

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request(request)
    end

    Array(JSON.parse(response.body)['droplets']) rescue []
  end
end
