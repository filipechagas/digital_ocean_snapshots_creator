class SnapshotProcessManager
  def initialize(droplet_id,
                 digital_ocean_caller,
                 droplet_snapshotter,
                 droplet_killer,
                 droplet_raiser,
                 logger)
    @droplet_id           = droplet_id
    @digital_ocean_caller = digital_ocean_caller
    @logger               = logger
    @droplet_snapshotter  = droplet_snapshotter
    @droplet_killer       = droplet_killer
    @droplet_raiser       = droplet_raiser
  end

  def perform
    power_droplet_off if is_droplet_active?
    create_snapshot
    power_droplet_on unless is_droplet_active?
  end

  private
  def is_droplet_active?
    @logger.debug("Checking if droplet is active - #{ @droplet_id }")

    droplet = @digital_ocean_caller.droplet_details(@droplet_id)
    droplet.fetch('status', '') == 'active'
  end

  def create_snapshot
    @logger.debug("Sending create snapshot message - #{ @droplet_id }")

    @droplet_snapshotter.perform
  end

  def power_droplet_on
    @logger.debug("Sending power on message - #{ @droplet_id }")

    @droplet_raiser.perform
  end

  def power_droplet_off
    @logger.debug("Sending power off message #{ @droplet_id }")

    @droplet_killer.perform
  end
end
