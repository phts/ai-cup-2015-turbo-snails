require './model/tile_type'
require_relative 'env'

class Tile
  CORNER_TYPES = [
                   TileType::LEFT_TOP_CORNER,
                   TileType::RIGHT_TOP_CORNER,
                   TileType::LEFT_BOTTOM_CORNER,
                   TileType::RIGHT_BOTTOM_CORNER,
                 ]

  INNER_ACCESSIBLE_PADDING = 140

  attr_reader :type
  attr_reader :x
  attr_reader :y

  def Tile.under(unit)
    Env.world.tiles_x_y.each_with_index do |columns, x|
      columns.each_with_index do |tile_type, y|
        tile = Tile.new(x, y, tile_type)
        return tile if tile.contains?(unit)
      end
    end
    nil
  end

  def Tile.at(x, y, empty_is_nil = false)
    return nil if x < 0 || x >= Env.world.width || y < 0 || y >= Env.world.height
    tile = Tile.new(x, y, Env.world.tiles_x_y[x][y])
    return nil if empty_is_nil && tile.type == TileType::EMPTY
    tile
  end

  def initialize(x, y, type = nil)
    @x = x
    @y = y
    @type = type
  end

  def contains?(unit)
    return unit.x >= x    * Env.game.track_tile_size &&
           unit.x < (x+1) * Env.game.track_tile_size &&
           unit.y >= y    * Env.game.track_tile_size &&
           unit.y < (y+1) * Env.game.track_tile_size
  end

  def center_real_x
    (x + 0.5) * Env.game.track_tile_size
  end

  def center_real_y
    (y + 0.5) * Env.game.track_tile_size
  end

  def real_coords
    cx = center_real_x
    cy = center_real_y
    left_x = x * Env.game.track_tile_size
    top_y = y * Env.game.track_tile_size
    right_x = (x+1) * Env.game.track_tile_size - 1
    bottom_y = (y+1) * Env.game.track_tile_size - 1
    inner_top_left_x = left_x + INNER_ACCESSIBLE_PADDING
    inner_top_left_y = top_y + INNER_ACCESSIBLE_PADDING
    inner_top_right_x = right_x - INNER_ACCESSIBLE_PADDING
    inner_top_right_y = inner_top_left_y
    inner_bottom_left_x = inner_top_left_x
    inner_bottom_left_y = bottom_y - INNER_ACCESSIBLE_PADDING
    inner_bottom_right_x = inner_top_right_x
    inner_bottom_right_y = inner_bottom_left_y

    {
      center_x: cx,
      center_y: cy,
      left_x: left_x,
      top_y: top_y,
      right_x: right_x,
      bottom_y: bottom_y,
      top_left_x: left_x,
      top_left_y: top_y,
      top_center_x: cx,
      top_center_y: top_y,
      top_right_x: right_x,
      top_right_y: top_y,
      right_center_x: right_x,
      right_center_y: cy,
      bottom_right_x: right_x,
      bottom_right_y: bottom_y,
      bottom_center_x: cx,
      bottom_center_y: bottom_y,
      bottom_left_x: left_x,
      bottom_left_y: bottom_y,
      left_center_x: left_x,
      left_center_y: cy,
      inner_top_left_x: inner_top_left_x,
      inner_top_left_y: inner_top_left_y,
      inner_top_right_x: inner_top_right_x,
      inner_top_right_y: inner_top_right_y,
      inner_bottom_left_x: inner_bottom_left_x,
      inner_bottom_left_y: inner_bottom_left_y,
      inner_bottom_right_x: inner_bottom_right_x,
      inner_bottom_right_y: inner_bottom_right_y,
    }
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

  def equals?(another)
    x == another.x && y == another.y
  end

  def accessible_neighbour?(another)
    n = neighbours
    return n[:top] && another.equals?(n[:top]) ||
           n[:right] && another.equals?(n[:right]) ||
           n[:bottom] && another.equals?(n[:bottom]) ||
           n[:left] && another.equals?(n[:left])
  end

  def neighbours
    {
      top: Tile.at(x, y-1, true),
      right: Tile.at(x+1, y, true),
      bottom: Tile.at(x, y+1, true),
      left: Tile.at(x-1, y, true),
    }
  end

  def accessible_neighbours
    n = neighbours
    case type
    when TileType::VERTICAL
      n[:right] = n[:left] = nil
    when TileType::HORIZONTAL
      n[:top] = n[:bottom] = nil
    when TileType::LEFT_TOP_CORNER
      n[:left] = n[:top] = nil
    when TileType::RIGHT_TOP_CORNER
      n[:right] = n[:top] = nil
    when TileType::LEFT_BOTTOM_CORNER
      n[:left] = n[:bottom] = nil
    when TileType::RIGHT_BOTTOM_CORNER
      n[:right] = n[:bottom] = nil
    when TileType::LEFT_HEADED_T
      n[:right] = nil
    when TileType::RIGHT_HEADED_T
      n[:left] = nil
    when TileType::TOP_HEADED_T
      n[:bottom] = nil
    when TileType::BOTTOM_HEADED_T
      n[:top] = nil
    when TileType::CROSSROADS
    end
    n
  end

  def corner?
    CORNER_TYPES.include?(type)
  end

  def delta(another)
    {x: x - another.x, y: y - another.y}
  end

end
