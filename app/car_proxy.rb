require './model/car'
require_relative 'proxy'
require_relative 'env'
require_relative 'tile'

class CarProxy < Proxy

  ANGLE_FOR_OTHER_CARS_IN_FRONT = 0.174

  def initialize(car)
    super(car)
    @using_nitro = car.engine_power == 2
  end

  def speed
    @speed ||= Math.hypot(subject.speed_x, subject.speed_y)
  end

  def next_waypoint
    @next_waypoint ||= Tile.at(subject.next_waypoint_x, subject.next_waypoint_y)
  end

  def tile
    @tile ||= Tile.under(subject)
  end

  def next_to?(tile)
    self.tile.accessible_neighbour?(tile)
  end

  def my?(car)
    Env.world.players.find{ |p| p.id == car.player_id }.me
  end

  def has_other_cars_in_front?
    Env.world.cars.each do |car|
      next if my?(car)
      return true if subject.angle_to_unit(car).abs < ANGLE_FOR_OTHER_CARS_IN_FRONT &&
                     subject.distance_to_unit(car) < Env.game.track_tile_size*2
    end
    false
  end

  def destroyed?
    Env.me.durability == 0
  end

  def using_nitro?
    @using_nitro
  end

  def nearest(units)
    @nearest ||= units.min_by{|u| u.distance_to(subject.x, subject.y) }
  end

end
