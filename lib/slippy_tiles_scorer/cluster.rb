# frozen_string_literal: true

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

    def clusters
      @tiles_x_y.each do |i|
        next if visited?(i[0], i[1])
        visit!(i[0], i[1])
        find_cluster_around(i)
      end
      { clusters: @clusters, cluster_tiles: @cluster_tiles }
    end

    private

    def find_cluster_around(start)
      cluster = []
      cluster.push(start)
      todo = [start]
      broad_search!(todo, cluster)

      @clusters.push(cluster) if cluster.size > 0
      cluster
    end

    def neighbors_up_down_left_right?(neighbors)
      neighbors.all? { |n| @tiles_x_y.include?(n) }
    end

    def broad_search!(todo, cluster) # rubocop:disable Metrics/MethodLength
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

    def visit!(x, y)
      @visited[x] ||= {}
      @visited[x][y] = true
    end

    def visited?(x, y)
      @visited.dig(x, y)
    end

    def neighbor_points(x, y)
      [[x - 1, y], [x + 1, y], [x, y + 1], [x, y - 1]]
    end
  end
end
