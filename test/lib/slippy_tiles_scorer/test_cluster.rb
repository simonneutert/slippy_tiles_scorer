# frozen_string_literal: true

require "test/unit"

class ClusterTest < Test::Unit::TestCase
  def setup
    @service = SlippyTilesScorer::Cluster.new
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

  def test_return_values_cluster_service # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    stub_tiles_x_y(service: @service, size: 100)
    assert_equal(10_000, @service.tiles_x_y.length)
    result = @service.clusters

    assert(result.is_a?(Hash))
    assert_equal(result.keys.length, 2)
    assert_equal(%i[clusters cluster_tiles], result.keys)

    assert(result[:clusters].is_a?(Array))
    assert(result[:clusters].first.is_a?(Set))
    assert(result[:clusters].first.first.is_a?(Array))
    assert(result[:clusters].first.first.size == 2)
    assert(result[:clusters].first.first.first.is_a?(Integer))
    assert(result[:clusters].first.first.last.is_a?(Integer))
    assert(result[:cluster_tiles])
    assert(result[:cluster_tiles].is_a?(Set))
    assert(result[:cluster_tiles].first.is_a?(Array))
    assert(result[:cluster_tiles].first.size == 2)
    assert(result[:cluster_tiles].first.first.is_a?(Integer))
    assert(result[:cluster_tiles].first.last.is_a?(Integer))
  end
end
