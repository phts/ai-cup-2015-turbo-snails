require 'singleton'
require 'forwardable'
require_relative 'car_proxy'
require_relative 'path_finder'
require_relative 'waypoint'

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

  def tile_count_before_next_subwaypoint
    # TODO: should count not until next_subwaypoint but next corner
    d = Env.me.tile.delta(next_subwaypoint)
    d[:x] == 0 ? d[:y].abs : d[:x].abs
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
    convert_to_waypoints!(sws)
    assign_directions(sws)
    sws
  end

  def convert_to_waypoints!(sws)
    sws.map! { |t| Waypoint.from_tile(t) }
  end

  def assign_directions(sws)
    (sws+[sws.first]).each_cons(2) do |swp|
      d = swp[0].delta(swp[1])
      if d[:x] > 0
        swp[0].next_direction = :left
      elsif d[:x] < 0
        swp[0].next_direction = :right
      elsif d[:y] > 0
        swp[0].next_direction = :top
      else
        swp[0].next_direction = :bottom
      end
    end
  end

  def filter_corners(path)
    path.select{ |t| t.corner? }
  end

  def update_next_subwaypoint_index
    csw = Tile.under(Env.me)
    if (subwaypoints[@next_subwaypoint_index].equals? csw)
      @next_subwaypoint_index = (@next_subwaypoint_index+1) % subwaypoints.count
    end
  end

end
