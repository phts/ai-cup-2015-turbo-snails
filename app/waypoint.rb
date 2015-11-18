require './model/tile_type'
require_relative 'env'
require_relative 'tile'

class Waypoint < Tile
  attr_accessor :next_direction
  attr_accessor :from_direction
  attr_accessor :original

  def Waypoint.at(*args)
    Waypoint.from_tile(super(*args))
  end

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
        px = if Env.me.x < rc[:inner_left_x]
               rc[:inner_left_x]
             elsif Env.me.x > rc[:inner_right_x]
               rc[:inner_right_x]
             else
               Env.me.x
             end
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
        py = if Env.me.y < rc[:inner_top_y]
               rc[:inner_top_y]
             elsif Env.me.y > rc[:inner_bottom_y]
               rc[:inner_bottom_y]
             else
               Env.me.y
             end
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
      elsif type == TileType::RIGHT_HEADED_T
        px = rc[:inner_right_x]
        py = next_direction == :top ? rc[:inner_top_y] : rc[:inner_bottom_y]
      elsif type == TileType::LEFT_HEADED_T
        px = rc[:inner_left_x]
        py = next_direction == :top ? rc[:inner_top_y] : rc[:inner_bottom_y]
      elsif type == TileType::BOTTOM_HEADED_T
        px = next_direction == :left ? rc[:inner_left_x] : rc[:inner_right_x]
        py = rc[:inner_bottom_y]
      elsif type == TileType::TOP_HEADED_T
        px = next_direction == :left ? rc[:inner_left_x] : rc[:inner_right_x]
        py = rc[:inner_top_y]
      end
    end

    [px, py]
  end

  def corner?
    return true if super
    return !(from_direction == :bottom && next_direction == :top ||
             from_direction == :top && next_direction == :bottom ||
             from_direction == :left && next_direction == :right ||
             from_direction == :right && next_direction == :left)
  end
end
