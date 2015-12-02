require './model/tile_type'
require_relative 'env'
require_relative 'tile'

class Waypoint < Tile
  attr_accessor :next_direction
  attr_accessor :from_direction
  attr_accessor :original
  attr_accessor :selected_bonus

  attr_writer :enable_brake

  def Waypoint.at(*args)
    Waypoint.from_tile(super(*args))
  end

  def Waypoint.from_tile(tile)
    Waypoint.new(tile.x, tile.y, tile.type)
  end

  def Waypoint.with_bonus(bonus)
    w = Waypoint.from_tile(Tile.under(bonus))
    w.enable_brake = false
    w.selected_bonus = bonus
    w
  end

  def initialize(*args)
    super(*args)
    @enable_brake = true
  end

  def preferable_for_me_real_coords(subwaypoints)
    rc = real_coords
    current_tile = Env.me.tile
    self_next_to_me = self.accessible_neighbour?(current_tile)

    if self_next_to_me
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

    if self_next_to_me
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

    if self_next_to_me
      wp_after_self = subwaypoints[subwaypoints.next_subwaypoint_index+1]
      wp_after_after_self = subwaypoints[subwaypoints.next_subwaypoint_index+2]
      wp_before_self = subwaypoints[subwaypoints.next_subwaypoint_index-1]

      # Check if zigzag then move straight through all corners
      if wp_before_self.equals?(current_tile) &&
         self.accessible_neighbour?(wp_before_self) && self.accessible_neighbour?(wp_after_self) &&
         wp_after_self.accessible_neighbour?(wp_after_after_self) &&
         wp_after_self.corner? && wp_before_self.corner? &&
         wp_after_after_self.from_direction == self.from_direction && wp_after_after_self.next_direction == self.next_direction
        @enable_brake = false
        if self.from_direction == :left && self.next_direction == :top && wp_after_self.next_direction == :right
          #  ╔
          # →╝
          px = rc[:center_x]
          py = rc[:top_y]
        elsif self.from_direction == :left && self.next_direction == :bottom && wp_after_self.next_direction == :right
          # →╗
          #  ╚
          px = rc[:center_x]
          py = rc[:bottom_y]
        elsif self.from_direction == :bottom && self.next_direction == :right && wp_after_self.next_direction == :top
          # ╔╝
          # ↑
          px = rc[:right_x]
          py = rc[:center_y]
        elsif self.from_direction == :bottom && self.next_direction == :left && wp_after_self.next_direction == :top
          # ╚╗
          #  ↑
          px = rc[:left_x]
          py = rc[:center_y]
        elsif self.from_direction == :top && self.next_direction == :right && wp_after_self.next_direction == :bottom
          # ↓
          # ╚╗
          px = rc[:right_x]
          py = rc[:center_y]
        elsif self.from_direction == :top && self.next_direction == :left && wp_after_self.next_direction == :bottom
          #  ↓
          # ╔╝
          px = rc[:left_x]
          py = rc[:center_y]
        elsif self.from_direction == :right && self.next_direction == :bottom && wp_after_self.next_direction == :left
          # ╔←
          # ╝
          px = rc[:center_x]
          py = rc[:bottom_y]
        elsif self.from_direction == :right && self.next_direction == :top && wp_after_self.next_direction == :left
          # ╗
          # ╚←
          px = rc[:center_x]
          py = rc[:top_y]
        end
      end

      # Check if a sharp turn
      if self.accessible_neighbour?(wp_after_self) && wp_after_self.corner? &&
         self.from_direction == wp_after_self.next_direction
        if self.from_direction == :bottom && self.next_direction == :right
          # ╔╗
          # ↑
          px = rc[:center_x]
          py = rc[:bottom_y]
        elsif self.from_direction == :left && self.next_direction == :top
          #  ╗
          # →╝
          px = rc[:left_x]
          py = rc[:center_y]
        elsif self.from_direction == :left && self.next_direction == :bottom
          # →╗
          #  ╝
          px = rc[:left_x]
          py = rc[:center_y]
        elsif self.from_direction == :top && self.next_direction == :right
          # ↓
          # ╚╝
          px = rc[:center_x]
          py = rc[:top_y]
        elsif self.from_direction == :top && self.next_direction == :left
          #  ↓
          # ╚╝
          px = rc[:center_x]
          py = rc[:top_y]
        elsif self.from_direction == :right && self.next_direction == :bottom
          # ╔←
          # ╚
          px = rc[:right_x]
          py = rc[:center_y]
        elsif self.from_direction == :right && self.next_direction == :top
          # ╔
          # ╚←
          px = rc[:right_x]
          py = rc[:center_y]
        elsif self.from_direction == :bottom && self.next_direction == :left
          # ╔╗
          #  ↑
          px = rc[:center_x]
          py = rc[:bottom_y]
        end
      end
    end

    if selected_bonus
      px, py = selected_bonus.x, selected_bonus.y
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

  def enable_brake?
    return false unless !!@enable_brake
    self.corner?
  end
end
