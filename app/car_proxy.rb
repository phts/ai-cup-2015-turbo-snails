require './model/car'
require './model/car_type'
require_relative 'proxy'
require_relative 'env'
require_relative 'tile'

class CarProxy < Proxy

  ANGLE_TO_SHOOT_FOR_BUGGY = 0.15
  ANGLE_TO_SHOOT_FOR_JEEP = 0.5

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

  def ready_to_shoot?
    return false if no_projectiles?
    return false if subject.remaining_projectile_cooldown_ticks != 0
    if subject.type == CarType::BUGGY
      Env.world.cars.each do |car|
        next if my?(car)
        return true if subject.angle_to_unit(car).abs < ANGLE_TO_SHOOT_FOR_BUGGY &&
                       subject.distance_to_unit(car) < Env.game.track_tile_size
      end
    else
      ready = false
      Env.world.cars.each do |car|
        next if my?(car)

        # To ensure that projectile will not disappear after shooting
        # due to http://russianaicup.ru/forum/index.php?topic=521.0
        return false if subject.distance_to_unit(car) <= Env.game.car_width

        ready = true if subject.angle_to_unit(car).abs < ANGLE_TO_SHOOT_FOR_JEEP &&
                        subject.distance_to_unit(car) > Env.game.car_width &&
                        tile.equals?(Tile.under(car))
      end
      return true if ready
    end
    false
  end

  def ready_to_spill_oil?
    return false if no_oil_canisters?
    return false if subject.remaining_oil_cooldown_ticks != 0
    Env.me.tile.corner?
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

  def no_oil_canisters?
    subject.oil_canister_count == 0
  end

  def no_projectiles?
    subject.projectile_count == 0
  end

end
