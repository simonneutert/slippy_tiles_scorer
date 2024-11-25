# frozen_string_literal: true

module SlippyTilesScorer
  # finds the maximum square in a collection/tiles_x_y of points (x, y)
  class MaxSquare
    attr_accessor :tiles_x_y

    def initialize(tiles_x_y: Set.new)
      @tiles_x_y = Marshal.load(Marshal.dump(tiles_x_y))
    end

    # @param min_size [Integer] The minimum size of the square, should be 3 or greater.
    #   As the smallest square is 3x3 and therefor a cluster tile needs to be the center.
    # @return [Hash] The size of the square and the points of the square.
    def max_squares(min_size: 3)
      raise ArgumentError, 'min_size must be 2 or greater' if min_size < 2

      result = { size: min_size, top_left_tile_x_y: Set.new }
      @tiles_x_y.each do |(x, y)|
        raise ArgumentError, 'x and y must be greater than or equal to 0' if x.negative? || y.negative?

        steps = max_square(x: x, y: y)
        track_result(result: result, steps: steps, x: x, y: y) if steps >= min_size
      end
      result
    end

    def max_square(x:, y:) # rubocop:disable Naming/MethodParameterName
      steps = 1
      steps += 1 while steps_fulfilled?(x: x, y: y, steps: steps)
      steps
    end

    def steps_fulfilled?(x:, y:, steps:) # rubocop:disable Naming/MethodParameterName
      @tiles_x_y.include?([x + steps, y + steps]) &&
        (0...steps).all? do |i|
          @tiles_x_y.include?([x + steps, y + i]) &&
            @tiles_x_y.include?([x + i, y + steps])
        end
    end

    private

    def track_result(result:, steps:, x:, y:) # rubocop:disable Naming/MethodParameterName
      if steps > result[:size]
        result[:size] = steps
        result[:top_left_tile_x_y] = Set.new
        result[:top_left_tile_x_y] << [x, y]
      elsif steps == result[:size]
        result[:top_left_tile_x_y] << [x, y]
      end
      result
    end
  end
end
