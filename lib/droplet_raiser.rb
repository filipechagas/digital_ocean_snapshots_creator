class DropletRaiser
  def initialize(droplet_id, digital_ocean_caller, logger)
    @digital_ocean_caller = digital_ocean_caller
    @droplet_id = droplet_id
    @logger = logger
  end

  def perform
    action = sends_snapshot_creation_message
    wait_until_action_is_completed(action)

    return true
  end

  private
  def sends_snapshot_creation_message
    @digital_ocean_caller.power_droplet_on(@droplet_id)
  end

  def wait_until_action_is_completed(action)
    begin
      sleep 10
    end until is_action_complete?(action.fetch('id'))
  end

  def is_action_complete?(action_id)
    @logger.debug("Checking if action is completed - #{ @droplet_id } - #{ action_id }")

    action_details = @digital_ocean_caller.action_details(action_id)
    action_details.fetch('status') == 'completed'
  end
end
