require 'net/http'
    require 'uri'
    require 'json'

class DigitalOceanCaller
  BASE_URL  = "https://api.digitalocean.com/v2/"

  def snapshot_by_tag(tag_name)
    url = BASE_URL + "droplets/actions?tag_name=#{ tag_name }"
    params = {
      "type" => "snapshot",
      "name" => DateTime.now.strftime("%Y%m%d-%T Snapshot")
    }
    post(url, params)
  end

  def power_off_by_tag(tag_name)
    url = BASE_URL + "droplets/actions?tag_name=#{ tag_name }"
    params = {'type' => 'power_off'}
    post(url, params)
  end

  def tag_droplets(droplets_ids, tag_name)
    tag_or_untag(droplets_ids, tag_name, 'post')
  end

  def untag_droplets(droplets_ids, tag_name)
    tag_or_untag(droplets_ids, tag_name, 'delete')
  end

  def action_details(action_id)
    url = BASE_URL + "actions/#{ action_id }"
    get(url, {})['action']
  end

  def all_droplets
    url = BASE_URL + "droplets?per_page=100"
    response = get(url, {})
    Array(response['droplets'])
  end

  private
  def tag_or_untag(droplets_ids, tag_name, post_or_delete)
    url = BASE_URL + "tags/#{ tag_name }/resources"

    params = {
      "resources" => droplets_ids.map do |droplet_id|
        { "resource_id" => droplet_id, "resource_type" => "droplet" }
      end
    }
    send(post_or_delete, url, params)
  end

  def post(url, params)
    http_request(url, params, 'Post')
  end

  def delete(url, params)
    http_request(url, params, 'Delete')
  end

  def get(url, params)
    http_request(url, params, 'Get')
  end

  def http_request(url, params, verb)
    uri = URI.parse(url)

    verb_klass = Kernel.const_get("Net::HTTP::#{ verb }")
    request = verb_klass.new(uri)

    request.content_type = "application/json"
    request["Authorization"] = "Bearer #{ ENV['DO_AUTHORIZATION'] }"
    request.body = JSON.dump(params)

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request(request)
    end

    unless response.code.to_s =~ /\A4../
      JSON.parse(response.body || '{}')
    else
      raise RuntimeError, JSON.parse(response.body)['message']
    end
  end
end
