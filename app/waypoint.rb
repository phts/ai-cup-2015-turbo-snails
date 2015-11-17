require './model/tile_type'
require_relative 'env'
require_relative 'tile'

class Waypoint < Tile

  def Waypoint.from_tile(tile)
    Waypoint.new(tile.x, tile.y, tile.type)
  end

  def initialize(*args)
    super(*args)
  end

  def preferable_for_me_real_coords
    rc = real_coords
    if Env.me.x < rc[:left_x]
      px = rc[:left_x]
    elsif Env.me.x > rc[:right_x]
      px = rc[:right_x]
    else
      if Env.me.tile.accessible_neighbour?(self)
        px = Env.me.x
      else
        px = rc[:center_x]
      end
    end
    if Env.me.y < rc[:top_y]
      py = rc[:top_y]
    elsif Env.me.y > rc[:bottom_y]
      py = rc[:bottom_y]
    else
      if Env.me.tile.accessible_neighbour?(self)
        py = Env.me.y
      else
        py = rc[:center_y]
      end
    end

    if Env.me.next_to?(self)
      if type == TileType::LEFT_TOP_CORNER
        px = rc[:inner_bottom_right_x]
        py = rc[:inner_bottom_right_y]
      elsif type == TileType::RIGHT_TOP_CORNER
        px = rc[:inner_bottom_left_x]
        py = rc[:inner_bottom_left_y]
      elsif type == TileType::LEFT_BOTTOM_CORNER
        px = rc[:inner_top_right_x]
        py = rc[:inner_top_right_y]
      elsif type == TileType::RIGHT_BOTTOM_CORNER
        px = rc[:inner_top_left_x]
        py = rc[:inner_top_left_y]
      end
    end

    [px, py]
  end
end
