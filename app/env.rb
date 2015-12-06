require_relative 'car_proxy'

class Env

  def Env.update(me, world, game, move, subwaypoints)
    @@me = CarProxy.new(me)
    @@world = world
    @@game = game
    @@move = move
    subwaypoints.update
  end

  def Env.me
    @@me
  end

  def Env.world
    @@world
  end

  def Env.game
    @@game
  end

  def Env.move
    @@move
  end

  def Env.after_tick?(tick)
    Env.world.tick > tick
  end

  def Env.started?
    Env.after_tick?(Env.game.initial_freeze_duration_ticks)
  end

  def Env.game2x2?
    Env.world.players.count == 2
  end

end
