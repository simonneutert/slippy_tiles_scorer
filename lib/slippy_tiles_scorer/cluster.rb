# frozen_string_literal: true

require "set"

module SlippyTilesScorer
  # Finds connected clusters in a collection of x/y tiles.
  class Cluster
    MISSING = Object.new.freeze
    private_constant :MISSING

    attr_accessor :tiles_x_y

    def initialize(tiles_x_y: Set.new)
      @tiles_x_y = tiles_x_y
    end

    # @return [Hash] The clusters and the tiles surrounded on all four sides.
    def clusters # rubocop:disable Metrics/MethodLength
      tile_index = build_tile_index

      clusters = []
      cluster_tiles = Set.new

      @tiles_x_y.each do |start|
        x = start[0]
        y = start[1]

        row = tile_index[y]

        # nil means this tile was already visited.
        next unless row && row[x]

        row[x] = nil

        cluster = [start]
        todo = [start]

        broad_search!(
          todo,
          cluster,
          cluster_tiles,
          tile_index
        )

        clusters << cluster
      end

      {
        clusters: clusters,
        cluster_tiles: cluster_tiles
      }
    end

    private

    # Builds a sparse coordinate lookup.
    #
    # Values initially contain the original tile Array:
    #
    #   {
    #     y => {
    #       x => [x, y]
    #     }
    #   }
    #
    # Once a tile has been scheduled for traversal its value becomes nil.
    # Hash#key? / Hash#fetch can therefore still distinguish:
    #
    #   missing  -> MISSING
    #   visited  -> nil
    #   unvisited -> [x, y]
    #
    def build_tile_index # rubocop:disable Metrics/MethodLength
      index = {}

      @tiles_x_y.each do |tile|
        x = tile[0]
        y = tile[1]

        row = index[y]

        if row
          row[x] = tile
        else
          index[y] = { x => tile }
        end
      end

      index
    end

    def broad_search!(todo, cluster, cluster_tiles, tile_index) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
      until todo.empty?
        point = todo.pop

        x = point[0]
        y = point[1]

        row = tile_index[y]

        left_x = x - 1
        right_x = x + 1

        left = row.fetch(left_x, MISSING)
        right = row.fetch(right_x, MISSING)

        down_row = tile_index[y + 1]
        up_row = tile_index[y - 1]

        down = down_row ? down_row.fetch(x, MISSING) : MISSING
        up = up_row ? up_row.fetch(x, MISSING) : MISSING

        if !left.equal?(MISSING) &&
           !right.equal?(MISSING) &&
           !down.equal?(MISSING) &&
           !up.equal?(MISSING)
          cluster_tiles.add(point)
        end

        if left && !left.equal?(MISSING)
          row[left_x] = nil
          todo << left
          cluster << left
        end

        if right && !right.equal?(MISSING)
          row[right_x] = nil
          todo << right
          cluster << right
        end

        if down && !down.equal?(MISSING)
          down_row[x] = nil
          todo << down
          cluster << down
        end

        next unless up && !up.equal?(MISSING)

        up_row[x] = nil
        todo << up
        cluster << up
      end
    end
  end
end
