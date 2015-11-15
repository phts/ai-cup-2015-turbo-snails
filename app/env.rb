require 'singleton'
require 'forwardable'

class Env
  include Singleton

  attr_reader :me
  attr_reader :world
  attr_reader :game
  attr_reader :move

  def update(me, world, game, move)
    @me = me
    @world = world
    @game = game
    @move = move
  end

  class << self
    extend Forwardable
    def_delegators :instance, *Env.instance_methods(false)
  end
end
