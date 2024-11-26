# frozen_string_literal: true

require "test/unit"

class MainTest < Test::Unit::TestCase # rubocop:disable Metrics/ClassLength
  def setup
    @service = SlippyTilesScorer::Score.new
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

  # def teardown
  # end

  def test_editable_coll
    stub_tiles_x_y(service: @service, size: 100)
    assert_equal(10_000, @service.tiles_x_y.length)

    @service.tiles_x_y.delete([5, 5])
    assert_equal(9_999, @service.tiles_x_y.length)
  end

  def test_steps_fulfilled_collection_full # rubocop:disable Metrics/AbcSize
    stub_tiles_x_y(service: @service, size: 100)
    assert_equal(10_000, @service.tiles_x_y.length)

    assert(@service.send(:steps_fulfilled?, x: 0, y: 0, steps: 2))
    assert(@service.send(:steps_fulfilled?, x: 0, y: 0, steps: 3))
    assert(@service.send(:steps_fulfilled?, x: 0, y: 0, steps: 4))
    assert(@service.send(:steps_fulfilled?, x: 0, y: 0, steps: 5))
    assert(@service.send(:steps_fulfilled?, x: 0, y: 0, steps: 12))
    assert(@service.send(:steps_fulfilled?, x: 0, y: 0, steps: 99))
    refute(@service.send(:steps_fulfilled?, x: 0, y: 0, steps: 100))
    refute(@service.send(:steps_fulfilled?, x: 0, y: 0, steps: 101))
  end

  def test_coll_empty
    assert_equal(0, @service.tiles_x_y.length)
    assert_equal({ size: 0, top_left_tile_x_y: Set.new }, @service.max_squares)
  end

  def test_max_square_no_entries_big_enough
    stub_tiles_x_y(service: @service, size: 1)
    result = @service.max_squares
    assert_equal(0, result[:size])
    assert_equal(0, result[:top_left_tile_x_y].length)
  end

  def test_steps_fulfilled_collection_holes
    stub_tiles_x_y(service: @service, size: 100)
    @service.tiles_x_y.delete([5, 5])

    assert(@service.send(:steps_fulfilled?, x: 0, y: 0, steps: 2))
    assert(@service.send(:steps_fulfilled?, x:  0, y: 0, steps: 3))
    assert(@service.send(:steps_fulfilled?, x:  0, y: 0, steps: 4))
    refute(@service.send(:steps_fulfilled?, x:  0, y: 0, steps: 5))
  end

  def test_max_steps_collection_with_holes
    stub_tiles_x_y(service: @service, size: 50)
    @service.tiles_x_y.delete([5, 5])

    assert_equal(5, @service.max_square(x: 0, y: 0))
    assert_equal(4, @service.max_square(x: 1, y: 1))

    result = @service.max_squares
    assert_equal(44, result[:size])
    assert_equal(13, result[:top_left_tile_x_y].length)
  end

  def test_max_steps_collection_with_holes_big
    stub_tiles_x_y(service: @service, size: 100)
    @service.tiles_x_y.delete([5, 5])
    result = @service.max_squares
    assert_equal(94, result[:size])
    assert_equal(13, result[:top_left_tile_x_y].length)
  end

  def test_clusters_easy # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    cluster_size = 50
    stub_tiles_x_y(service: @service, size: cluster_size)
    assert_equal(2500, @service.tiles_x_y.length)
    # divide vertically at x==20
    (0..cluster_size).each { |i| @service.tiles_x_y.delete([20, i]) }

    assert_equal(2450, @service.tiles_x_y.length)

    result = @service.clusters
    clusters = result[:clusters]
    cluster_tiles = result[:cluster_tiles]
    clusters_of_cluster_tiles = result[:clusters_of_cluster_tiles]
    assert_equal(2, clusters.size)
    assert_equal(2160, cluster_tiles.size)
    assert_equal(2, clusters_of_cluster_tiles.size)
  end

  def test_clusters_triple # rubocop:disable Metrics/AbcSize,Metrics/MethodLength,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
    stub_tiles_x_y(service: @service, size: 50)
    assert_equal(2500, @service.tiles_x_y.length)

    (0...50).each do |i|
      @service.tiles_x_y.delete([20, i])
    end

    @service.tiles_x_y.delete([5, 5])
    @service.tiles_x_y.delete([5, 6])
    @service.tiles_x_y.delete([5, 7])
    @service.tiles_x_y.delete([5, 8])
    @service.tiles_x_y.delete([5, 9])
    @service.tiles_x_y.delete([5, 10])
    @service.tiles_x_y.delete([6, 10])
    @service.tiles_x_y.delete([7, 10])
    @service.tiles_x_y.delete([8, 10])
    @service.tiles_x_y.delete([9, 10])
    @service.tiles_x_y.delete([10, 10])
    @service.tiles_x_y.delete([10, 9])
    @service.tiles_x_y.delete([10, 8])
    @service.tiles_x_y.delete([10, 7])
    @service.tiles_x_y.delete([10, 6])
    @service.tiles_x_y.delete([10, 5])
    @service.tiles_x_y.delete([9, 5])
    @service.tiles_x_y.delete([8, 5])
    @service.tiles_x_y.delete([7, 5])
    @service.tiles_x_y.delete([6, 5])

    assert_equal(2430, @service.tiles_x_y.length)

    # calculate clusters
    result = @service.clusters
    cluster_tiles = result[:cluster_tiles]
    clusters = result[:clusters]
    clusters_of_cluster_tiles = result[:clusters_of_cluster_tiles]
    assert_equal([16, 964, 1450], clusters.map(&:size).sort)
    assert_equal(3, clusters.size)
    assert_equal(2104, cluster_tiles.size)
    assert(cluster_tiles.length == clusters_of_cluster_tiles.map(&:size).sum)
    assert_equal([4, 804, 1296], clusters_of_cluster_tiles.map(&:size).sort)

    # calculate max squares
    max_squares = clusters.map { |cluster| @service.max_squares(tiles_x_y: cluster) }.sort_by { |square| square[:size] }
    assert_equal([4, 20, 29], max_squares.map { |square| square[:size] })
    smallest_max_square = max_squares.find { |square| square[:size] == 4 }
    assert_equal(1, smallest_max_square[:top_left_tile_x_y].length)
    assert_equal(Set.new.add([6, 6]), smallest_max_square[:top_left_tile_x_y])
  end

  def test_return_values_cluster_service
    stub_tiles_x_y(service: @service, size: 50)
    result_clusters = @service.clusters
    assert(result_clusters.key?(:clusters))
    assert(result_clusters.key?(:cluster_tiles))
    assert(result_clusters.key?(:clusters_of_cluster_tiles))
  end

  def test_return_values_cluster_service_for_clusters # rubocop:disable Metrics/AbcSize
    stub_tiles_x_y(service: @service, size: 50)
    result_clusters = @service.clusters
    assert(result_clusters[:clusters].is_a?(Array))
    assert(result_clusters[:clusters].first.is_a?(Array))
    assert(result_clusters[:clusters].first.first.is_a?(Array))
    assert(result_clusters[:clusters].first.first.size == 2)
    assert_equal([0, 0], result_clusters[:clusters].first.first)
  end

  def test_return_values_cluster_service_for_cluster_tiles # rubocop:disable Metrics/AbcSize
    stub_tiles_x_y(service: @service, size: 50)
    result_clusters = @service.clusters
    assert(result_clusters[:cluster_tiles].is_a?(Set))
    assert(result_clusters[:cluster_tiles].first.is_a?(Array))
    assert(result_clusters[:cluster_tiles].first.size == 2)
    assert(result_clusters[:cluster_tiles].first.first.is_a?(Integer))
    assert(result_clusters[:cluster_tiles].first.last.is_a?(Integer))
  end

  def test_return_values_cluster_service_for_clusters_of_cluster_tiles # rubocop:disable Metrics/AbcSize
    stub_tiles_x_y(service: @service, size: 50)
    result_clusters = @service.clusters
    assert(result_clusters[:clusters_of_cluster_tiles].is_a?(Array))
    assert(result_clusters[:clusters_of_cluster_tiles].first.is_a?(Array))
    assert(result_clusters[:clusters_of_cluster_tiles].first.first.is_a?(Array))
    assert(result_clusters[:cluster_tiles].first.first.is_a?(Integer))
    assert(result_clusters[:cluster_tiles].first.last.is_a?(Integer))
  end

  def test_readme_example # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
    collection_of_tiles = Set.new
    collection_of_tiles.add([0, 0])
    collection_of_tiles.add([0, 1])
    collection_of_tiles.add([1, 0])
    collection_of_tiles.add([1, 1])
    collection_of_tiles.add([0, 2])
    collection_of_tiles.add([1, 2])
    collection_of_tiles.add([2, 0])
    collection_of_tiles.add([2, 1])
    collection_of_tiles.add([2, 2])
    assert_equal(9, collection_of_tiles.length)
    # puts Score.new(tiles_x_y collection_of_tiles).clusters
    # puts Score.new(tiles_x_y collection_of_tiles).max_squares
    # puts Score.new(tiles_x_y collection_of_tiles).max_squares(min_size: 4)

    tile_scorer = SlippyTilesScorer::Score.new(tiles_x_y: collection_of_tiles)
    result_clusters = tile_scorer.clusters
    clusters = result_clusters[:clusters]

    max_squares_of_clusters = clusters.flat_map do |cluster|
      tile_scorer.max_squares(tiles_x_y: cluster)
    end
    max_squares_max_size = max_squares_of_clusters.map { |max_square| max_square[:size] }.max
    assert_equal(1, (max_squares_of_clusters.select { |max_square| max_square[:size] == max_squares_max_size }).size)
  end
end
