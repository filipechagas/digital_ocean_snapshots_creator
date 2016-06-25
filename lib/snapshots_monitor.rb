require 'lib/digital_ocean_caller'

class SnapshotsMonitor
  ACTIVE_DROPLET_TAG='active_droplet'
  SNAPSHOT_BACKUP_TAG='snapshot_backup'

  def initialize
    @digital_ocean_caller ||= DigitalOceanCaller.new
  end

  def perform
    begin
      tag_all_droplets_with_snapshot_backup_tag
      tag_active_droplets_with_active_droplet_tag
      response = trigger_power_off_for_all_tagged_droplets
      wait_until_all_droplets_are_powered_off(response)
      trigger_snapshots_for_all_droplets
    ensure
      untag_all_droplets
    end
    puts 'COMPLETED'
  end

  private
  def untag_all_droplets
    CustomLogger.log.info 'untag_all_droplets'
    droplets_ids = droplets.map{|droplet| droplet['id'] }
    @digital_ocean_caller.
      untag_droplets(droplets_ids, SNAPSHOT_BACKUP_TAG)
    @digital_ocean_caller.
      untag_droplets(droplets_ids, ACTIVE_DROPLET_TAG)
  end

  def trigger_snapshots_for_all_droplets
    CustomLogger.log.info 'trigger_snapshots_for_all_droplets'

    @digital_ocean_caller.snapshot_by_tag( SNAPSHOT_BACKUP_TAG )
  end

  def wait_until_all_droplets_are_powered_off(response)
    CustomLogger.log.info 'wait_until_all_droplets_are_powered_off'
    actions = response.fetch('actions', [])

    begin
      sleep 10
    end until all_actions_finished?(actions)
  end

  def trigger_power_off_for_all_tagged_droplets
    CustomLogger.log.info 'trigger_power_off_for_all_tagged_droplets'
    @digital_ocean_caller.power_off_by_tag( ACTIVE_DROPLET_TAG )
  end

  def tag_all_droplets_with_snapshot_backup_tag
    CustomLogger.log.info 'tag_all_droplets_with_snapshot_backup_tag'

    droplets_ids = droplets.map{|droplet| droplet['id'] }
    @digital_ocean_caller.
      tag_droplets(droplets_ids, SNAPSHOT_BACKUP_TAG)
  end

  def tag_active_droplets_with_active_droplet_tag
    CustomLogger.log.info 'tag_active_droplets_with_active_droplet_tag'

    droplets_ids = droplets.
      select{|droplet| droplet['status'] == 'active'}.
      map{|droplet| droplet['id'] }

    @digital_ocean_caller.
      tag_droplets(droplets_ids, ACTIVE_DROPLET_TAG) if droplets_ids.any?
  end

  def droplets
    @droplets ||= reload_droplets
  end

  def reload_droplets
    CustomLogger.log.info 'reload_droplets'

    @droplets ||= @digital_ocean_caller.all_droplets
  end

  def all_actions_finished?(actions)
    CustomLogger.log.info 'all_actions_finished?'

    actions_details = []
    actions.each do |action|
      actions_details << @digital_ocean_caller.action_details(action['id'])
    end
    actions_details.all?{|action| action['status'] == 'completed'}
  end
end
