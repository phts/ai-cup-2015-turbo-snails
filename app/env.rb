require 'singleton'
require 'forwardable'
require_relative 'car_proxy'
require_relative 'subwaypoints'

class Env
  include Singleton

  TICK_COUNT_WHEN_GOT_STUCK = 40
  TICK_COUNT_LIMIT_WHEN_GOT_STUCK = 200
  REPARING_POSITION_TICK_COUNT = 100

  attr_reader :me
  attr_reader :world
  attr_reader :game
  attr_reader :move

  def initialize
    @low_speed_count = 0
    @reparing_position_ticks = 0
  end

  def update(me, world, game, move)
    @me = CarProxy.new(me)
    @world = world
    @game = game
    @move = move
    Subwaypoints.update
  end

  def started?
    Env.world.tick > Env.game.initial_freeze_duration_ticks
  end

  def got_stuck?
    return false unless Env.started?
    if reparing_position?
      if @reparing_position_ticks > REPARING_POSITION_TICK_COUNT
        @reparing_position_ticks = 0
        return false
      else
        return true
      end
    end
    if Env.me.speed < 0.1
      @low_speed_count += 1
    else
      @low_speed_count = 0
    end
    return (TICK_COUNT_WHEN_GOT_STUCK..TICK_COUNT_LIMIT_WHEN_GOT_STUCK).include? @low_speed_count
  end

  def reparing_position?
    @reparing_position_ticks != 0
  end

  def repare_position
    @reparing_position_ticks += 1
    if @reparing_position_ticks == REPARING_POSITION_TICK_COUNT
      Subwaypoints.use_rebuilt_path_to_next(Env.me.tile)
    end
    Env.move.engine_power = -1.0
    Env.move.wheel_turn = -Env.move.wheel_turn
    Env.move.brake = false
  end

  class << self
    extend Forwardable
    def_delegators :instance, *Env.instance_methods(false)
  end

end
