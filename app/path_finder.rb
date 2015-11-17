class PathFinder

  def initialize(start_tile, end_tile)
    @start_tile = start_tile
    @end_tile = end_tile
  end

  # Retunrs array. First item is start_tile and last item is end_tile
  def find_shortest_path
    node = find_end_tile
    expand_path(node)
  end

  private

  def find_end_tile
    level = [{self: @start_tile}]
    @tree = [level]
    while true
      level = []
      @tree[-1].each do |node|
        nbs = node[:self].accessible_neighbours

        top_neighbour = nbs[:top]
        if top_neighbour && !tree_contains_tile?(top_neighbour)
          top_neighbour_node = {self: top_neighbour, parent: node}
          return top_neighbour_node if top_neighbour.equals?(@end_tile)
          level << top_neighbour_node
        end
        right_neighbour = nbs[:right]
        if right_neighbour && !tree_contains_tile?(right_neighbour)
          right_neighbour_node = {self: right_neighbour, parent: node}
          return right_neighbour_node if right_neighbour.equals?(@end_tile)
          level << right_neighbour_node
        end
        bottom_neighbour = nbs[:bottom]
        if bottom_neighbour && !tree_contains_tile?(bottom_neighbour)
          bottom_neighbour_node = {self: bottom_neighbour, parent: node}
          return bottom_neighbour_node if bottom_neighbour.equals?(@end_tile)
          level << bottom_neighbour_node
        end
        left_neighbour = nbs[:left]
        if left_neighbour && !tree_contains_tile?(left_neighbour)
          left_neighbour_node = {self: left_neighbour, parent: node}
          return left_neighbour_node if left_neighbour.equals?(@end_tile)
          level << left_neighbour_node
        end
      end
      @tree << level
    end
  end

  def expand_path(node)
    path = []
    path << node[:self]
    until node[:parent].nil?
      node = node[:parent]
      path << node[:self]
    end
    path.reverse
  end

  def tree_contains_tile?(tile)
    @tree.each do |level|
      return true if level.index{ |node| tile.equals?(node[:self]) }
    end
    false
  end

end
