require 'lib/digital_ocean_caller'

class SnapshotsMonitor
  def initialize
    @digital_ocean_caller ||= DigitalOceanCaller.new
  end

  def perform
    droplets
  end

  private
  def droplets
    @droplets ||= @digital_ocean_caller.all_droplets.select do |droplet|
      droplet['id'] == 15110818
    end
  end
end
