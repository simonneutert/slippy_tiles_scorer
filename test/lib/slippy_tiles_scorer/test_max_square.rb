# frozen_string_literal: true

require "test/unit"

class MaxSquareTest < Test::Unit::TestCase
  def setup
    @service_cluster = SlippyTilesScorer::Cluster.new
    @service_max_square = SlippyTilesScorer::MaxSquare.new
  end

  def stub_tiles_x_y(service:, size: 50)
    service.tiles_x_y = Set.new
    (0...size).each do |i|
      (0...size).each do |j|
        service.tiles_x_y.add([i, j])
      end
    end
    service
  end

  def test_return_values_max_square_service # rubocop:disable Metrics/AbcSize
    stub_tiles_x_y(service: @service_max_square, size: 100)
    assert_equal(10_000, @service_max_square.tiles_x_y.length)
    result = @service_max_square.max_squares

    assert(result.is_a?(Hash))
    assert_equal(%i[size top_left_tile_x_y], result.keys)
    assert(result[:size].is_a?(Integer))
    assert(result[:top_left_tile_x_y].is_a?(Set))
    assert(result[:top_left_tile_x_y].first.is_a?(Array))
    assert(result[:top_left_tile_x_y].first.all?(Integer))
  end

  def test_result_for_multiple_max_squares # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    stub_tiles_x_y(service: @service_max_square, size: 100)
    @service_max_square.tiles_x_y.delete([5, 5])
    @service_max_square.tiles_x_y.delete([5, 6])
    @service_max_square.tiles_x_y.delete([5, 7])
    @service_max_square.tiles_x_y.delete([5, 8])
    @service_max_square.tiles_x_y.delete([5, 9])
    @service_max_square.tiles_x_y.delete([5, 10])
    @service_max_square.tiles_x_y.delete([6, 10])
    @service_max_square.tiles_x_y.delete([7, 10])
    @service_max_square.tiles_x_y.delete([8, 10])
    @service_max_square.tiles_x_y.delete([9, 10])
    @service_max_square.tiles_x_y.delete([10, 10])
    @service_max_square.tiles_x_y.delete([10, 9])
    @service_max_square.tiles_x_y.delete([10, 8])
    @service_max_square.tiles_x_y.delete([10, 7])
    @service_max_square.tiles_x_y.delete([10, 6])
    @service_max_square.tiles_x_y.delete([10, 5])
    @service_max_square.tiles_x_y.delete([9, 5])
    @service_max_square.tiles_x_y.delete([8, 5])
    @service_max_square.tiles_x_y.delete([7, 5])
    @service_max_square.tiles_x_y.delete([6, 5])
    result = @service_max_square.max_squares
    assert_equal(23, result[:top_left_tile_x_y].length)
    assert(result[:top_left_tile_x_y].include?([11, 1]))
  end
end
