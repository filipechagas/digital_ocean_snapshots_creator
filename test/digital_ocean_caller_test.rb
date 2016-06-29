require_relative './test_helper'

require 'test/support/fake_logger'
require 'lib/digital_ocean_caller'

describe DigitalOceanCaller do
  before do
    @caller = DigitalOceanCaller.new(FakeLogger)
  end

  let(:action_id){ 100 }
  let(:action_details){{
    "action"=> {
      "id"=> 36804636,
      "status"=> "completed",
      "type"=> "create",
      "started_at"=> "2014-11-14T16=>29=>21Z",
      "completed_at"=> "2014-11-14T16=>30=>06Z",
      "resource_id"=> 3164444,
      "resource_type"=> "droplet",
      "region"=> "nyc3",
      "region_slug"=> "nyc3"
    }
  }}


  describe '#snapshot' do
    it 'returns action details' do
      droplet_id = 100
      stub_request(:post, "https://api.digitalocean.com/v2/droplets/#{ droplet_id }/actions").
        to_return(:status => 200, :body => JSON.dump(action_details), :headers => {})


      @caller.snapshot(droplet_id).must_equal ( action_details['action'] )
    end
  end

  describe '#snapshot_by_tag' do
    it 'returns an empty hash' do
      stub_request(:post, "https://api.digitalocean.com/v2/droplets/actions?tag_name=TAG").
        to_return(:status => 200, :body => "{}", :headers => {})

      @caller.snapshot_by_tag('TAG').must_equal ( Hash.new )
    end
  end

  describe '#droplet_details' do
    it 'returns droplet details' do
      droplet_details = {
        "droplet"=> {
          "id"=> 3164494,
          "name"=> "example.com",
          "status"=> "active",
          "created_at"=> "2014-11-14T16=>36=>31Z",
        }
      }

      stub_request(:get, "https://api.digitalocean.com/v2/droplets/101010").
        to_return(:status => 200, :body => JSON.dump( droplet_details ), :headers => {})

      @caller.droplet_details('101010').must_equal ( droplet_details['droplet'] )
    end
  end

  describe '#power_droplet_on' do
    it 'returns action details' do
      droplet_id = 100

      stub_request(:post, "https://api.digitalocean.com/v2/droplets/#{droplet_id}/actions").
        with(:body => "{\"type\":\"power_on\"}").
        to_return(:status => 200, :body => JSON.dump(action_details), :headers => {})


      @caller.power_droplet_on(droplet_id).must_equal ( action_details['action'] )
    end
  end

  describe '#power_droplet_off' do
    it 'returns action details' do
      droplet_id = 100

      stub_request(:post, "https://api.digitalocean.com/v2/droplets/#{droplet_id}/actions").
        with(:body => "{\"type\":\"power_off\"}").
        to_return(:status => 200, :body => JSON.dump(action_details), :headers => {})

      @caller.power_droplet_off(droplet_id).must_equal ( action_details['action'] )
    end
  end

  describe '#power_off_by_tag' do
    it 'returns an empty hash' do
      tag_name = "TAG"

      stub_request(:post, "https://api.digitalocean.com/v2/droplets/actions?tag_name=#{ tag_name }").
        with(:body => "{\"type\":\"power_off\"}").
        to_return(:status => 200, :body => "", :headers => {})

      @caller.power_off_by_tag(tag_name).must_equal ( {} )
    end
  end

  describe '#power_on_by_tag' do
    it 'returns an empty hash' do
      tag_name = "TAG"

      stub_request(:post, "https://api.digitalocean.com/v2/droplets/actions?tag_name=#{ tag_name }").
        with(:body => "{\"type\":\"power_on\"}").
        to_return(:status => 200, :body => "", :headers => {})

      @caller.power_on_by_tag(tag_name).must_equal ( {} )
    end
  end

  describe '#tag_droplets' do
    it 'returns an empty hash' do
      droplets_ids = %w(100 101 102)
      json_droplets_ids = JSON.dump({ resources: droplets_ids.map{|id| {resource_id: id, resource_type: 'droplet'}} })
      tag_name = 'TAG'

      stub_request(:post, "https://api.digitalocean.com/v2/tags/#{ tag_name }/resources").
        with(:body => json_droplets_ids).
        to_return(:status => 200, :body => "", :headers => {})


      @caller.tag_droplets(droplets_ids, tag_name).must_equal ( {} )
    end
  end

  describe '#untag_droplets' do
    it 'returns an empty hash' do
      droplets_ids = %w(100 101 102)
      json_droplets_ids = JSON.dump({ resources: droplets_ids.map{|id| {resource_id: id, resource_type: 'droplet'}} })
      tag_name = 'TAG'

      stub_request(:delete, "https://api.digitalocean.com/v2/tags/#{ tag_name }/resources").
        with(:body => json_droplets_ids).
        to_return(:status => 200, :body => "", :headers => {})


      @caller.untag_droplets(droplets_ids, tag_name).must_equal ( {} )
    end
  end

  describe '#action_details' do
    it 'returns hash with action details' do
      stub_request(:get, "https://api.digitalocean.com/v2/actions/#{ action_id }").
        to_return(:status => 200, :body => JSON.dump(action_details), :headers => {})


        @caller.action_details(action_id).must_equal ( action_details['action'] )
    end
  end

  describe '#all_droplets' do
    it 'returns a hash with all droplets' do

      all_droplets = %w(100 101 102).map{|id|{
        "id" => id,
        "name" => 'example.com',
        "memory" => 512,
        "vcpus" => 1,
        "disk" => 20,
        "locked" => false,
        "status" => "active",
        "created_at" => "2014-11-14T16:29:21Z",
      }}


      json_droplets = JSON.dump({ droplets: all_droplets })

      stub_request(:get, "https://api.digitalocean.com/v2/droplets?per_page=100").
        to_return(:status => 200, :body => json_droplets, :headers => {})

      @caller.all_droplets.must_equal ( all_droplets )
    end
  end
end
