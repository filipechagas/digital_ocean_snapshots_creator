require_relative './test_helper'

require 'test/support/fake_logger'
require 'lib/snapshot_process_manager'

describe SnapshotProcessManager do
  let(:do_caller){ Minitest::Mock.new  }
  let(:droplet_snapshotter){ Minitest::Mock.new }
  let(:droplet_killer){ Minitest::Mock.new }
  let(:droplet_raiser){ Minitest::Mock.new }
  let(:droplet_id){ 100 }

  subject{ SnapshotProcessManager.new(droplet_id,
                                      do_caller,
                                      droplet_snapshotter,
                                      droplet_killer,
                                      droplet_raiser,
                                      FakeLogger)}

  before do
    do_caller.expect(:droplet_details, droplet_details('active'), [ droplet_id ])
    do_caller.expect(:droplet_details, droplet_details('off'), [ droplet_id ])
  end

  it 'delegates droplet off, snapshot and on' do
    droplet_killer.expect(:perform, nil)
    droplet_raiser.expect(:perform, nil)
    droplet_snapshotter.expect(:perform, nil)

    subject.perform

    do_caller.verify
    droplet_killer.verify
    droplet_raiser.verify
    droplet_snapshotter.verify
  end

  def droplet_details(droplet_status)
    {
      "id"=> droplet_id,
      "name"=> "example.com",
      "status"=> droplet_status,
      "created_at"=> "2014-11-14T16=>36=>31Z",
    }
  end
end
