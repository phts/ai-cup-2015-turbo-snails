require './model/car'
require_relative 'proxy'

class CarProxy < Proxy

  def initialize(car)
    super(car)
  end

  def speed
    Math.hypot(subject.speed_x, subject.speed_y)
  end

  def next_waypoint
    Tile.at(subject.next_waypoint_x, subject.next_waypoint_y)
  end

  def tile
    Tile.under(subject)
  end

  def next_to?(tile)
    self.tile.accessible_neighbour?(tile)
  end

end
