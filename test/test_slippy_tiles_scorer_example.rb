# frozen_string_literal: true

require "test/unit"
require_relative "../test_helper"

class ExampleTest < Test::Unit::TestCase
  def setup
    @service = SlippyTilesScorer::Score.new
    @data = JSON.parse(File.read("test/resources/jsontiledata_202407080909.json"))
  end

  def test_score_for_example # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    @tiles_zoom16 = @data.select { |tile| tile["z"] == 16 }.to_set { |tile| [tile["x"], tile["y"]] }
    assert_equal(38_728, @tiles_zoom16.size)

    cluster_data = @service.clusters(tiles_x_y: @tiles_zoom16)
    clusters = cluster_data[:clusters]
    assert_equal(71, cluster_data[:clusters].size)
    assert_equal(1111, cluster_data[:clusters_of_cluster_tiles].size)
    assert_equal(5450, cluster_data[:cluster_tiles].size)
    max_cluster = cluster_data[:clusters_of_cluster_tiles].max_by(&:size)
    assert_equal(2515, max_cluster.size)

    max_squares = clusters.map { |cluster| @service.max_squares(tiles_x_y: cluster) }
    max_square = max_squares.max_by { |ms| ms[:size] }
    assert_equal(16, max_square[:size])
  end
end
