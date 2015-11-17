require './model/car'
require './model/game'
require './model/move'
require './model/world'
require_relative 'env'
require_relative 'tile'

class MyStrategy

  def move(me, world, game, move)
    Env.update(me, world, game, move)

    waypoint = Env.next_subwaypoint

    angel_to_waypoint = Env.me.angle_to(*waypoint.preferable_for_me_real_coords)

    Env.move.engine_power = 1
    Env.move.wheel_turn = angel_to_waypoint * 32 / Math::PI

    if Env.me.tile.accessible_neighbour?(waypoint) && waypoint.corner?
      Env.move.brake = true if Env.me.speed > 15
    end

    if Env.world.tick > Env.game.initial_freeze_duration_ticks
      if Env.tile_count_before_next_subwaypoint > 2
        Env.move.use_nitro = true
      end
    end
  end

end
