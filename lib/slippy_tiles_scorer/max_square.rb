# frozen_string_literal: true

require "set"

module SlippyTilesScorer
  # finds the maximum square in a collection/tiles_x_y of points (x, y)
  class MaxSquare
    attr_accessor :tiles_x_y

    def initialize(tiles_x_y: Set.new)
      @tiles_x_y = tiles_x_y
      @tiles_lut = nil
    end

    # @param min_size [Integer] The minimum size of the square, should be 3 or greater.
    #   As the smallest square is 3x3 and therefor a cluster tile needs to be the center.
    # @return [Hash] The size of the square and the points of the square.
    def max_squares(min_size: 3)
      @max_size_found = 0
      raise ArgumentError, "min_size must be 2 or greater" if min_size < 2

      result = max_square_result(min_size: min_size)
      @max_size_found = 0
      @tiles_lut = nil
      result
    end

    # @param min_size [Integer] The minimum size of the square, should be 3 or greater.
    # @return [Hash] The size of the square and the points of the square.
    def max_square_result(min_size: 3)
      result = { size: @max_size_found, top_left_tile_x_y: Set.new }
      @tiles_x_y.each do |(x, y)|
        raise ArgumentError, "x and y must be greater than or equal to 0" if x.negative? || y.negative?

        steps = max_square(x: x, y: y)
        result = track_result(result: result, steps: steps, x: x, y: y) if steps >= min_size
      end
      result
    end

    # @param x [Integer] The x coordinate of the top left tile.
    # @param y [Integer] The y coordinate of the top left tile.
    # @return [Integer] The size of the square.
    def max_square(x:, y:)
      steps = 1
      steps += 1 while steps_fulfilled?(x: x, y: y, steps: steps)
      steps
    end

    # @param x [Integer] The x coordinate of the top left tile.
    # @param y [Integer] The y coordinate of the top left tile.
    # @param steps [Integer] The size of the square.
    # @return [Boolean] True if all steps are fulfilled.
    def steps_fulfilled?(x:, y:, steps:)
      in_lut?(x: x + steps, y: y + steps) &&
        (0...steps).all? do |i|
          in_lut?(x: x + steps, y: y + i) &&
            in_lut?(x: x + i, y: y + steps)
        end
    end

    private

    # This is as fast as it gets! Do not implement `#nil?
    #
    # @param x [Integer] The x coordinate of the top left tile.
    # @param y [Integer] The y coordinate of the top left tile.
    # @return [Boolean|Nil] True if the tile is in the tiles_lut.
    def in_lut?(x:, y:)
      unless @tiles_lut
        @tiles_lut = {}
        @tiles_x_y.each do |(x, y)|
          @tiles_lut[x] ||= {}
          @tiles_lut[x][y] = true
        end
      end
      @tiles_lut.dig(x, y)
    end

    # @param result [Hash] The result hash.
    # @param steps [Integer] The size of the square.
    # @param x [Integer] The x coordinate of the top left tile.
    # @param y [Integer] The y coordinate of the top left tile.
    # @return [Hash] The updated result hash.
    def track_result(result:, steps:, x:, y:)
      if steps > @max_size_found
        @max_size_found = steps
        result = { size: @max_size_found, top_left_tile_x_y: Set.new }
        update_result!(result: result, steps: steps, x: x, y: y)
      elsif steps == @max_size_found
        update_result!(result: result, steps: steps, x: x, y: y)
      end
      result
    end

    # @param result [Hash] The result hash.
    # @param steps [Integer] The size of the square.
    # @param x [Integer] The x coordinate of the top left tile.
    # @param y [Integer] The y coordinate of the top left tile.
    # @return [Hash] The updated result hash.
    def update_result!(result:, steps:, x:, y:)
      result[:size] = steps
      result[:top_left_tile_x_y] << [x, y]
      result
    end
  end
end
