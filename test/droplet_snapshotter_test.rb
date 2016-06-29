require_relative './test_helper'

require 'test/support/fake_logger'
require 'lib/droplet_snapshotter'

describe DropletSnapshotter do
  let(:do_caller){ Minitest::Mock.new }
  let(:droplet_id){ 100 }
  let(:action_id){ 36805022 }
  let(:action_details_body){{
    "id"            => action_id,
    "status"        => "completed",
    "type"          => "snapshot",
    "started_at"    => "2014-11-14T16 => 34 => 39Z",
    "completed_at"  => nil,
    "resource_id"   => 3164450,
    "resource_type" => "droplet",
    "region"        => "nyc3",
    "region_slug"   => "nyc3"
  }}

  subject{ DropletSnapshotter.new(droplet_id, do_caller, FakeLogger) }

  before do
    do_caller.expect(:snapshot, action_details_body, [ droplet_id ])
  end

  it 'sends snapshot message and waits until it is finished' do
    do_caller.expect(:action_details, action_details_body, [ action_id ])

    subject.stub :sleep, nil do
      subject.perform
    end

    do_caller.verify
  end
end
