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

    if Env.me.next_to?(self)
      if from_direction == :top && next_direction == :bottom ||
         from_direction == :bottom && next_direction == :top ||
         from_direction == :left && next_direction == :right ||
         from_direction == :right && next_direction == :left

        px = if Env.me.x < rc[:inner_left_x]
               rc[:inner_left_x]
             elsif Env.me.x > rc[:inner_right_x]
               rc[:inner_right_x]
             else
               Env.me.x
             end
        py = if Env.me.y < rc[:inner_top_y]
               rc[:inner_top_y]
             elsif Env.me.y > rc[:inner_bottom_y]
               rc[:inner_bottom_y]
             else
               Env.me.y
             end
      end
    end

    case from_direction
    when :top
      px = rc[:center_x]
      py = rc[:inner_top_y]
    when :right
      px = rc[:inner_right_x]
      py = rc[:center_y]
    when :bottom
      px = rc[:center_x]
      py = rc[:inner_bottom_y]
    when :left
      px = rc[:inner_left_x]
      py = rc[:center_y]
    end

    if Env.me.next_to?(self)
      if from_direction == :right && next_direction == :bottom ||
         from_direction == :bottom && next_direction == :right
        if Env.me.distance_to(rc[:inner_bottom_right_x], rc[:inner_bottom_right_y]) < Env.game.track_tile_size
          px = rc[:inner_bottom_right_x]
          py = rc[:inner_bottom_right_y]
        end

      elsif from_direction == :bottom && next_direction == :left ||
            from_direction == :left && next_direction == :bottom
        if Env.me.distance_to(rc[:inner_bottom_left_x], rc[:inner_bottom_left_y]) < Env.game.track_tile_size
          px = rc[:inner_bottom_left_x]
          py = rc[:inner_bottom_left_y]
        end

      elsif from_direction == :top && next_direction == :right ||
            from_direction == :right && next_direction == :top
        if Env.me.distance_to(rc[:inner_top_right_x], rc[:inner_top_right_y]) < Env.game.track_tile_size
          px = rc[:inner_top_right_x]
          py = rc[:inner_top_right_y]
        end

      elsif from_direction == :top && next_direction == :left ||
            from_direction == :left && next_direction == :top
        if Env.me.distance_to(rc[:inner_top_left_x], rc[:inner_top_left_y]) < Env.game.track_tile_size
          px = rc[:inner_top_left_x]
          py = rc[:inner_top_left_y]
        end
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
