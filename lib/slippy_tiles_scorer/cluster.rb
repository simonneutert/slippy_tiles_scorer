# frozen_string_literal: true

require "set"

module SlippyTilesScorer
  # finds clusters in a collection/tiles_x_y of points (x, y)
  class Cluster
    attr_accessor :tiles_x_y

    def initialize(tiles_x_y: Set.new)
      @tiles_x_y = tiles_x_y
      @cluster_tiles = Set.new
      @visited = {}
      @clusters = []
    end

    # @return [Hash] The clusters and the tiles in the clusters.
    def clusters
      @tiles_x_y.each do |i|
        next if visited?(i[0], i[1])

        visit!(i[0], i[1])
        find_cluster_around(i)
      end
      { clusters: @clusters, cluster_tiles: @cluster_tiles }
    end

    private

    # @param start [Array] The x and y coordinate of the start point.
    # @return [Array<Array<Integer, Integer>>] The cluster of points.
    def find_cluster_around(start)
      cluster = []
      cluster.push(start)
      todo = [start]
      broad_search!(todo, cluster)

      @clusters.push(cluster) if cluster.size.positive?
      cluster
    end

    # @param todo [Array] The points to visit.
    # @param cluster [Array] The cluster of points.
    def broad_search!(todo, cluster) # rubocop:disable Metrics/CyclomaticComplexity
      until todo.empty?
        point = todo.pop
        neighbors = neighbor_points(*point)
        neighbors_up_down_left_right?(neighbors) && @cluster_tiles.add(point)
        neighbors.each do |neighbor|
          next if visited?(neighbor[0], neighbor[1])
          next unless @tiles_x_y.include?(neighbor)

          visit!(*neighbor) && todo.push(neighbor) && cluster.push(neighbor)
        end
      end
    end

    # @param x [Integer] The x coordinate of the point.
    # @param y [Integer] The y coordinate of the point.
    # @return [Boolean] True if the point is visited.
    def visit!(x, y)
      @visited[x] ||= {}
      @visited[x][y] = true
    end

    # @param x [Integer] The x coordinate of the point.
    # @param y [Integer] The y coordinate of the point.
    # @return [Boolean|Nil] True if the point is visited.
    def visited?(x, y)
      @visited.dig(x, y)
    end

    # @param neighbors [Array] The neighbors of the point.
    # @return [Boolean] True if all neighbors are in the tiles_x_y.
    def neighbors_up_down_left_right?(neighbors)
      neighbors.all? { |n| @tiles_x_y.include?(n) }
    end

    # @param x [Integer] The x coordinate of the point.
    # @param y [Integer] The y coordinate of the point.
    # @return [Array<Array<Integer, Integer>>] The neighbors of the point.
    def neighbor_points(x, y)
      [[x - 1, y], [x + 1, y], [x, y + 1], [x, y - 1]]
    end
  end
end
