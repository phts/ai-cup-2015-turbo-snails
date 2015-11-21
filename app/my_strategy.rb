require './model/car'
require './model/game'
require './model/move'
require './model/world'
require_relative 'env'
require_relative 'tile'
require_relative 'subwaypoints'
require_relative 'moving'

class MyStrategy

  def move(me, world, game, move)
    Env.update(me, world, game, move)
    return if Env.me.destroyed?

    waypoint = Subwaypoints.next
    coords = waypoint.preferable_for_me_real_coords

    angel_to_waypoint = Env.me.angle_to(*coords)

    Env.move.engine_power = 1
    Env.move.wheel_turn = angel_to_waypoint * 32 / Math::PI

    if Env.me.next_to?(waypoint) && waypoint.corner?
      if Env.me.distance_to(*coords) < Env.game.track_tile_size
        Env.move.brake = true if Env.me.speed > 14
        Env.move.engine_power = -1 if Env.me.speed > 20
      end
    end

    if Env.me.tile.corner?
      Env.move.spill_oil = true
    end

    if Env.me.has_other_cars_in_front?
      Env.move.throw_projectile = true
    end

    if Moving.got_stuck?
      Moving.repare_position
      return
    end
    if Env.started?
      if Subwaypoints.tile_count_before_next > 2
        Env.move.use_nitro = true
      end
    end
  end

end
