require "json"
require 'net/http'
require 'uri'

class DigitalOceanCaller
  def snapshot_by_tag(tag_name)
    uri = URI.parse("https://api.digitalocean.com/v2/droplets/actions?tag_name=#{ tag_name }")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    request["Authorization"] = "Bearer #{ ENV['DO_AUTHORIZATION'] }"
    request.body = JSON.dump({
      "type" => "snapshot", "name" => DateTime.now.strftime("%Y%m%d-%T Snapshot")
    })

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request(request)
    end

    JSON.parse(response.body) rescue {}

  end
  def power_off_by_tag(tag_name)
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

    JSON.parse(response.body) rescue {}
  end

  def tag_droplets(droplets_ids, tag_name)
    uri = URI.parse("https://api.digitalocean.com/v2/tags/#{ tag_name }/resources")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    request["Authorization"] = "Bearer #{ ENV['DO_AUTHORIZATION'] }"
    request.body = JSON.dump({
      "resources" => droplets_ids.map do |droplet_id|
        { "resource_id" => droplet_id, "resource_type" => "droplet" }
      end
    })

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request(request)
    end

    JSON.parse(response.body) rescue {}
  end

  def untag_droplets(droplets_ids, tag_name)
    uri = URI.parse("https://api.digitalocean.com/v2/tags/#{ tag_name }/resources")
    request = Net::HTTP::Delete.new(uri)
    request.content_type = "application/json"
    request["Authorization"] = "Bearer #{ ENV['DO_AUTHORIZATION'] }"
    request.body = JSON.dump({
      "resources" => droplets_ids.map do |droplet_id|
        { "resource_id" => droplet_id, "resource_type" => "droplet" }
      end
    })

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request(request)
    end

    JSON.parse(response.body) rescue {}
  end

  def action_details(action_id)
    uri = URI.parse("https://api.digitalocean.com/v2/actions/#{ action_id }")
    request = Net::HTTP::Get.new(uri)
    request.content_type = "application/json"
    request["Authorization"] = "Bearer #{ ENV['DO_AUTHORIZATION'] }"

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request(request)
    end

    JSON.parse(response.body)['action'] rescue {}
  end

  def list_all_actions
    uri = URI.parse("https://api.digitalocean.com/v2/actions?page=1&per_page=1")
    request = Net::HTTP::Get.new(uri)
    request.content_type = "application/json"
    request["Authorization"] = "Bearer #{ ENV['DO_AUTHORIZATION'] }"

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request(request)
    end

    Array(JSON.parse(response.body)['actions']) rescue []
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

    JSON.parse(response.body) rescue {}
  end

  def all_droplets_by_tag(tag_name)
    uri = URI.parse("https://api.digitalocean.com/v2/droplets?tag_name=#{ tag_name }")
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{ ENV['DO_AUTHORIZATION'] }"

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request(request)
    end

    Array(JSON.parse(response.body)['droplets']) rescue []
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
