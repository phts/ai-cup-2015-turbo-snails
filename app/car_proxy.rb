require './model/car'
require_relative 'proxy'

class CarProxy < Proxy

  def initialize(car)
    super(car)
  end

  def next_waypoint
    Tile.at(subject.next_waypoint_x, subject.next_waypoint_y)
  end

end
