require './model/car'
require './model/game'
require './model/move'
require './model/world'
require_relative 'array'
require_relative 'env'
require_relative 'subwaypoints'
require_relative 'moving'

class MyStrategy

  def initialize
    @moving = Moving.new
    @subwaypoints = Subwaypoints.new
  end

  def move(me, world, game, move)
    Env.update(me, world, game, move, subwaypoints)
    return if Env.me.destroyed?

    waypoint = subwaypoints.next
    coords = waypoint.preferable_for_me_real_coords(subwaypoints)
    angel_to_waypoint = Env.me.angle_to(*coords)
    Env.move.wheel_turn = angel_to_waypoint * 5
    return unless Env.started?

    Env.move.engine_power = 1

    if waypoint.enable_brake?
      if (distance = Env.me.distance_to(*coords)) < Env.game.track_tile_size
        Env.move.brake = true if Env.me.speed > 14
        Env.move.engine_power = -1 if Env.me.speed > 20
      elsif distance < Env.game.track_tile_size*3
        Env.move.brake = true if Env.me.speed > 27
        Env.move.engine_power = -1 if Env.me.speed > 32
      end
    end
    if waypoint.force_brake? && Env.me.speed > 5
      Env.move.brake = true
    end

    if Env.me.ready_to_spill_oil?
      Env.move.spill_oil = true
    end

    if Env.me.ready_to_shoot?
      Env.move.throw_projectile = true
    end

    if moving.got_stuck?
      moving.repare_position(subwaypoints)
      return
    end
    if Env.after_tick?(250)
      if subwaypoints.tile_count_before_corner > 3
        Env.move.use_nitro = true
      end
    end
  end

  private

  attr_reader :moving
  attr_reader :subwaypoints

end
