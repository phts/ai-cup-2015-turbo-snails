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

    waypoint = Subwaypoints.next

    angel_to_waypoint = Env.me.angle_to(*waypoint.preferable_for_me_real_coords)

    Env.move.engine_power = 1
    Env.move.wheel_turn = angel_to_waypoint * 32 / Math::PI

    if Env.me.tile.accessible_neighbour?(waypoint) && waypoint.corner?
      Env.move.brake = true if Env.me.speed > 14
      Env.move.engine_power = -1 if Env.me.speed > 20
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
