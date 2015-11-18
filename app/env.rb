require 'singleton'
require 'forwardable'
require_relative 'car_proxy'
require_relative 'subwaypoints'

class Env
  include Singleton

  attr_reader :me
  attr_reader :world
  attr_reader :game
  attr_reader :move

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

  class << self
    extend Forwardable
    def_delegators :instance, *Env.instance_methods(false)
  end

end
