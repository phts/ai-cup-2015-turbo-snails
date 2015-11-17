require 'singleton'
require 'forwardable'
require_relative 'car_proxy'
require_relative 'path_finder'

class Env
  include Singleton

  attr_reader :me
  attr_reader :world
  attr_reader :game
  attr_reader :move
  attr_reader :next_subwaypoint_index

  def initialize
    @next_subwaypoint_index = 0
  end

  def update(me, world, game, move)
    @me = CarProxy.new(me)
    @world = world
    @game = game
    @move = move
    update_next_subwaypoint_index
  end

  def subwaypoints
    @subwaypoints ||= create_subwaypoints
  end

  def next_subwaypoint
    subwaypoints[@next_subwaypoint_index]
  end

  class << self
    extend Forwardable
    def_delegators :instance, *Env.instance_methods(false)
  end

  private

  def create_subwaypoints
    sws = []
    ws = Env.world.waypoints.map {|p| Tile.at(p[0], p[1])}
    ws.each_cons(2) do |p|
      sws << p[0]
      path = PathFinder.new(p[0], p[1]).find_shortest_path
      path_without_start_and_end = path[1..-2]
      sws += filter_corners(path_without_start_and_end)
    end
    sws << ws[-1]
    path = PathFinder.new(ws[-1], ws[0]).find_shortest_path
    sws += filter_corners(path)
    sws
  end

  def filter_corners(path)
    path.select{ |t| t.corner? }
  end

  def update_next_subwaypoint_index
    csw = Tile.under(Env.me)
    index = subwaypoints.index{|sw| sw.equals?(csw)}
    return unless index
    @next_subwaypoint_index = (index+1) % subwaypoints.count
  end

end
