require_relative 'env'

class Tile
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

  def Tile.at(x, y)
    Tile.new(x, y, Env.world.tiles_x_y[x][y])
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

end
