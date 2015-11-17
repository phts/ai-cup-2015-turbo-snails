require './model/car'
require './model/game'
require './model/move'
require './model/world'
require_relative 'env'
require_relative 'tile'

class MyStrategy

  def move(me, world, game, move)
    Env.update(me, world, game, move)

    waypoint = Env.me.next_waypoint

    corner_tile_offset = 0.25 * Env.game.track_tile_size
    case waypoint.type
    when TileType::LEFT_TOP_CORNER
      corner_tile_offset_x = corner_tile_offset
      corner_tile_offset_y = corner_tile_offset
    when TileType::RIGHT_TOP_CORNER
      corner_tile_offset_x = -corner_tile_offset
      corner_tile_offset_y = corner_tile_offset
    when TileType::LEFT_BOTTOM_CORNER
      corner_tile_offset_x = corner_tile_offset
      corner_tile_offset_y = -corner_tile_offset
    when TileType::RIGHT_BOTTOM_CORNER
      corner_tile_offset_x = -corner_tile_offset
      corner_tile_offset_y = -corner_tile_offset
    else
      corner_tile_offset_x = corner_tile_offset
      corner_tile_offset_y = corner_tile_offset
    end

    angel_to_waypoint = Env.me.angle_to(waypoint.center_real_x + corner_tile_offset_x, waypoint.center_real_y + corner_tile_offset_y)
    speed_module = Math.hypot(Env.me.speed_x, Env.me.speed_y);

    Env.move.engine_power = 0.8
    Env.move.wheel_turn = angel_to_waypoint * 32 / Math::PI

    if (speed_module * speed_module * angel_to_waypoint.abs > 2.5 * 2.5 * Math::PI)
      Env.move.brake = true;
    end
  end

end
