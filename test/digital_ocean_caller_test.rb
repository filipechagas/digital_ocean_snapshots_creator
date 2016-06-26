require_relative './test_helper'

class Logger; def self.method_missing(*args); nil; end; end

describe DigitalOceanCaller do
  before do
    @caller = DigitalOceanCaller.new(Logger)
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
end
