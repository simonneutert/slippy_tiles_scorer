# frozen_string_literal: true

module SlippyTilesScorer
  # finds clusters in a collection/tiles_x_y of points (x, y)
  class Cluster
    attr_accessor :tiles_x_y

    def initialize(tiles_x_y: Set.new)
      @tiles_x_y = Marshal.load(Marshal.dump(tiles_x_y))
      @cluster_tiles = Set.new
      @visited = Set.new
      @clusters = []
    end

    def clusters
      while @tiles_x_y.any?
        start = @tiles_x_y.first
        @tiles_x_y.delete(start)
        @visited.add(start)
        find_cluster_around(start)
      end
      { clusters: @clusters, cluster_tiles: @cluster_tiles }
    end

    private

    def find_cluster_around(start)
      cluster = Set.new
      cluster.add(start)
      todo = [start]

      cluster = broad_search(todo, cluster)

      @clusters.push(cluster) if cluster.size > 1
      cluster
    end

    def neighbors_up_down_left_right?(neighbors)
      neighbors.all? { |n| @tiles_x_y.include?(n) || @visited.include?(n) }
    end

    def broad_search(todo, cluster) # rubocop:disable Metrics/MethodLength
      until todo.empty?
        point = todo.pop
        neighbors = neighbor_points(*point)

        next if neighbors.empty?

        @cluster_tiles.add(point) if neighbors_up_down_left_right?(neighbors)
        neighbors.each do |neighbor|
          next unless @tiles_x_y.include?(neighbor)
          next if @visited.include?(neighbor)

          @visited.add(neighbor)
          cluster.add(neighbor)
          todo.push(neighbor)
        end
      end
      cluster
    end

    def neighbor_points(x, y) # rubocop:disable Naming/MethodParameterName
      res = Set.new
      [[x - 1, y], [x + 1, y], [x, y + 1], [x, y - 1]].each { |point| res.add(point) }
      res
    end
  end
end
