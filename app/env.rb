require 'singleton'
require_relative 'car_proxy'

class Env
  include Singleton

  attr_reader :me
  attr_reader :world
  attr_reader :game
  attr_reader :move

  def Env.method_missing(method_sym, *arguments, &block)
    instance.send(method_sym, *arguments, &block)
  end

  def update(me, world, game, move, subwaypoints)
    @me = CarProxy.new(me)
    @world = world
    @game = game
    @move = move
    subwaypoints.update
  end

  def after_tick?(tick)
    Env.world.tick > tick
  end

  def started?
    Env.after_tick?(Env.game.initial_freeze_duration_ticks)
  end

end
