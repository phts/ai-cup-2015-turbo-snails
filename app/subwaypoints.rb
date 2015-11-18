require 'singleton'
require 'forwardable'
require_relative 'env'
require_relative 'tile'
require_relative 'path_finder'
require_relative 'waypoint'

class Subwaypoints
  include Singleton

  def initialize
    @next_subwaypoint_index = 0
    @rebuilt_subwaypoints = nil
    @next_rebuilt_subwaypoint_index = 0
  end

  def update
    csw = Tile.under(Env.me)
    if @rebuilt_subwaypoints
      if @rebuilt_subwaypoints[@next_rebuilt_subwaypoint_index].equals? csw
        @next_rebuilt_subwaypoint_index += 1
        if @next_rebuilt_subwaypoint_index >= @rebuilt_subwaypoints.count
          @rebuilt_subwaypoints = nil
        end
      end
    end
    if subwaypoints[@next_subwaypoint_index].equals? csw
      @next_subwaypoint_index = (@next_subwaypoint_index+1) % subwaypoints.count
    end
  end

  def next
    if @rebuilt_subwaypoints
      return @rebuilt_subwaypoints[@next_rebuilt_subwaypoint_index]
    end
    subwaypoints[@next_subwaypoint_index]
  end

  def tile_count_before_next
    d = Env.me.tile.delta(self.next)
    d[:x] == 0 ? d[:y].abs : d[:x].abs
  end

  def use_rebuilt_path_to_next(start_tile)
    @next_rebuilt_subwaypoint_index = 0
    end_tile = next_original_waypoint
    @next_subwaypoint_index = subwaypoints.index(end_tile)
    @rebuilt_subwaypoints = PathFinder.new(start_tile, end_tile).find_shortest_path
    convert_to_waypoints!(@rebuilt_subwaypoints)
    assign_directions!(@rebuilt_subwaypoints, subwaypoints[(@next_subwaypoint_index+1) % subwaypoints.count])
    @rebuilt_subwaypoints.slice!(0)
    filter_corners!(@rebuilt_subwaypoints)
  end

  class << self
    extend Forwardable
    def_delegators :instance, *Subwaypoints.instance_methods(false)
  end

  private

  def subwaypoints
    @subwaypoints ||= create_subwaypoints
  end

  def create_subwaypoints
    sws = []
    ws = Env.world.waypoints.map {|p| Waypoint.at(p[0], p[1])}
    (ws+[ws[0]]).each_cons(2) do |p|
      sws << p[0]
      path = PathFinder.new(p[0], p[1]).find_shortest_path
      sws += ignore_straight(path[1..-2])
    end
    convert_to_waypoints!(sws)
    assign_directions!(sws)
    filter_corners!(sws)
    sws
  end

  def convert_to_waypoints!(sws)
    sws.map! do |t|
      if t.instance_of? Waypoint
        t.original = true
      else
        t = Waypoint.from_tile(t)
      end
      t
    end
  end

  def assign_directions!(sws, closing_tile = sws.first)
    (sws+[closing_tile]).each_cons(2) do |swp|
      d = swp[0].delta(swp[1])
      if d[:x] > 0
        swp[0].next_direction = :left
        swp[1].from_direction = :right
      elsif d[:x] < 0
        swp[0].next_direction = :right
        swp[1].from_direction = :left
      elsif d[:y] > 0
        swp[0].next_direction = :top
        swp[1].from_direction = :bottom
      else
        swp[0].next_direction = :bottom
        swp[1].from_direction = :top
      end
    end
  end

  def filter_corners!(waypoints)
    waypoints.select!{ |w| w.original || w.corner? }
  end

  def ignore_straight(path)
    path.select{ |t| !t.straight? }
  end

  def next_original_waypoint
    i = @next_subwaypoint_index
    while true
      w = subwaypoints[i]
      return w if w.original
      i = (i+1) % subwaypoints.count
    end
  end

end
