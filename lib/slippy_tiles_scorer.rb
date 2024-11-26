# frozen_string_literal: true

require "set"
require_relative "slippy_tiles_scorer/version"
require_relative "slippy_tiles_scorer/cluster"
require_relative "slippy_tiles_scorer/max_square"

module SlippyTilesScorer
  class Error < StandardError; end

  # Score class to calculate the score of a collection of points (x, y)
  class Score
    attr_accessor :tiles_x_y

    def initialize(tiles_x_y: Set.new)
      @tiles_x_y = tiles_x_y
    end

    def valid?
      return true if @tiles_x_y.empty?
      raise ArgumentError, "@tiles_x_y must be a Set" unless @tiles_x_y.is_a?(Set)

      set_of_arrays? && set_of_arrays_of_integers?
    end

    def clusters(tiles_x_y: @tiles_x_y)
      service = SlippyTilesScorer::Cluster.new(tiles_x_y: tiles_x_y)
      result = service.clusters
      result[:clusters_of_cluster_tiles] =
        SlippyTilesScorer::Cluster.new(tiles_x_y: result[:cluster_tiles]).clusters[:clusters]
      result
    end

    def max_square(x:, y:, tiles_x_y: @tiles_x_y)
      SlippyTilesScorer::MaxSquare.new(tiles_x_y: tiles_x_y).max_square(x: x, y: y)
    end

    def max_squares(tiles_x_y: @tiles_x_y, min_size: 3)
      SlippyTilesScorer::MaxSquare.new(tiles_x_y: tiles_x_y).max_squares(min_size: min_size)
    end

    def steps_fulfilled?(x:, y:, steps:)
      SlippyTilesScorer::MaxSquare.new(tiles_x_y: @tiles_x_y).steps_fulfilled?(x: x, y: y, steps: steps)
    end

    def visited(tiles_x_y: @tiles_x_y)
      tiles_x_y.size
    end

    private

    def set_of_arrays?
      return true if @tiles_x_y.all? { |point| point.is_a?(Array) && point.size == 2 }

      raise ArgumentError, "each point must be an array with two elements"
    end

    def set_of_arrays_of_integers?
      return true if @tiles_x_y.all? { |point| point.all?(Integer) }

      raise ArgumentError, "each point must be an array with two integers"
    end
  end
end
