# frozen_string_literal: true

require "set"
require "json"
require "simplecov"

if ENV.fetch("NO_COVERAGE", false)
  SimpleCov.start do
    enable_coverage :branch
  end
else
  require "simplecov_small_badge"
  SimpleCov.start do
    enable_coverage :branch
    SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new(
      [
        SimpleCov::Formatter::HTMLFormatter,
        SimpleCovSmallBadge::Formatter
      ]
    )
  end
end

require "test/unit"
require_relative "test_helper"

require_relative "lib/slippy_tiles_scorer"
require_relative "lib/slippy_tiles_scorer/cluster"
require_relative "lib/slippy_tiles_scorer/max_square"

Dir.glob("./test/**/test_*.rb").each do |path|
  require_relative File.expand_path(path)
end

Test::Unit.at_start do
  require "benchmark"
  data = JSON.parse(
    File.read("test/resources/jsontiledata_202407080909.json"), symbolize_names: true
  )
  tiles_zoom16 = data.select { |tile| tile[:z] == 16 }.to_set { |tile| [tile[:x], tile[:y]] }
  service = SlippyTilesScorer::Score.new(tiles_x_y: tiles_zoom16)

  n = 10
  Benchmark.bm(35) do |x|
    x.report("SlippyTilesScorer::Cluster") do
      n.times do
        service.clusters
      end
    end

    x.report("SlippyTilesScorer::MaxSquare") do
      n.times do
        service.max_squares
      end
    end
  end
  puts "\n\nFinished Benchmarking\n\n"
end
