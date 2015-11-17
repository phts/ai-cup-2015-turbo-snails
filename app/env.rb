require 'singleton'
require 'forwardable'
require_relative 'car_proxy'
require_relative 'path_finder'
require_relative 'waypoint'

class Env
  include Singleton

  TICK_COUNT_WHEN_GOT_STUCK = 40
  TICK_COUNT_LIMIT_WHEN_GOT_STUCK = 200
  REPARING_POSITION_TICK_COUNT = 100

  attr_reader :me
  attr_reader :world
  attr_reader :game
  attr_reader :move
  attr_reader :next_subwaypoint_index

  def initialize
    @next_subwaypoint_index = 0
    @low_speed_count = 0
    @reparing_position_ticks = 0
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
    Env.move.engine_power = -1.0
    Env.move.wheel_turn = -Env.move.wheel_turn
    Env.move.brake = false
  end

  class << self
    extend Forwardable
    def_delegators :instance, *Env.instance_methods(false)
  end

  private

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

  def assign_directions!(sws)
    (sws+[sws.first]).each_cons(2) do |swp|
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

  def update_next_subwaypoint_index
    csw = Tile.under(Env.me)
    if (subwaypoints[@next_subwaypoint_index].equals? csw)
      @next_subwaypoint_index = (@next_subwaypoint_index+1) % subwaypoints.count
    end
  end

end
