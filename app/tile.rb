require './model/tile_type'
require_relative 'env'

class Tile
  CORNER_TYPES = [
                   TileType::LEFT_TOP_CORNER,
                   TileType::RIGHT_TOP_CORNER,
                   TileType::LEFT_BOTTOM_CORNER,
                   TileType::RIGHT_BOTTOM_CORNER,
                 ]

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
    return nil if x < 0 || x >= Env.world.tiles_x_y.count || y < 0 || y >= Env.world.tiles_x_y.count
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

  def equals?(another)
    x == another.x && y == another.y
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

end
