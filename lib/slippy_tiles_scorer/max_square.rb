# frozen_string_literal: true

require "set"

module SlippyTilesScorer
  # Finds the maximum fully-filled square in a collection of x/y tiles.
  class MaxSquare
    attr_reader :tiles_x_y

    def initialize(tiles_x_y: Set.new)
      self.tiles_x_y = tiles_x_y
    end

    def tiles_x_y=(tiles_x_y)
      @tiles_x_y = tiles_x_y
      @square_scores = nil
    end

    # Finds all largest fully-filled squares.
    #
    # @param min_size [Integer] Minimum square size to report.
    # @return [Hash] Maximum size and its top-left tile coordinates.
    def max_squares(min_size: 3)
      # Rebuild for every scoring run because tiles_x_y may be a mutable Set.
      @square_scores = nil

      max_square_result(min_size: min_size)
    end

    # @param min_size [Integer] Minimum square size to report.
    # @return [Hash] Maximum size and its top-left tile coordinates.
    def max_square_result(min_size: 3) # rubocop:disable Metrics/MethodLength
      raise ArgumentError, "min_size must be 2 or greater" if min_size < 2

      max_size = 0
      top_left_tiles = Set.new

      square_scores.each do |y, row|
        row.each do |x, size|
          next if size < min_size

          if size > max_size
            max_size = size
            top_left_tiles.clear
            top_left_tiles << [x, y]
          elsif size == max_size
            top_left_tiles << [x, y]
          end
        end
      end

      {
        size: max_size,
        top_left_tile_x_y: top_left_tiles
      }
    end

    # Returns the size of the largest fully-filled square whose
    # top-left tile is x/y.
    #
    # @param x [Integer] X coordinate of the top-left tile.
    # @param y [Integer] Y coordinate of the top-left tile.
    # @return [Integer] Square size, or 0 if the tile does not exist.
    def max_square(x:, y:)
      row = square_scores[y]

      return 0 unless row

      row[x] || 0
    end

    # Reports whether the square starting at x/y can grow beyond +steps+.
    #
    # For example:
    #   steps_fulfilled?(x: 0, y: 0, steps: 2)
    #
    # is true when a fully-filled square of at least 3x3 exists there.
    #
    # @param x [Integer] X coordinate of the top-left tile.
    # @param y [Integer] Y coordinate of the top-left tile.
    # @param steps [Integer] Current square size.
    # @return [Boolean]
    def steps_fulfilled?(x:, y:, steps:)
      max_square(x: x, y: y) > steps
    end

    private

    # Builds a sparse dynamic-programming lookup.
    #
    # For every existing tile:
    #
    #   score(x, y) =
    #     1 + min(
    #       score(x + 1, y),
    #       score(x, y + 1),
    #       score(x + 1, y + 1)
    #     )
    #
    # A score of N guarantees that every tile in the N x N square
    # beginning at x/y exists.
    #
    # @return [Hash<Integer, Hash<Integer, Integer>>]
    def square_scores
      @square_scores ||= build_square_scores
    end

    def build_square_scores # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
      rows = {}

      @tiles_x_y.each do |x, y|
        if x.negative? || y.negative?
          raise ArgumentError,
                "x and y must be greater than or equal to 0"
        end

        (rows[y] ||= []) << x
      end

      scores = {}

      next_row = nil
      next_y = nil

      rows.keys.sort.reverse_each do |y|
        # A gap between rows means no square can continue downward.
        next_row = nil unless next_y == y + 1

        current_row = {}

        rows[y].sort!.reverse_each do |x|
          right = current_row[x + 1] || 0

          if next_row
            below = next_row[x] || 0
            diagonal = next_row[x + 1] || 0
          else
            below = 0
            diagonal = 0
          end

          # Avoid allocating [right, below, diagonal] for every tile.
          min = [right, below].min
          min = diagonal if diagonal < min

          current_row[x] = min + 1
        end

        scores[y] = current_row
        next_row = current_row
        next_y = y
      end

      scores
    end
  end
end
