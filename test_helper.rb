# frozen_string_literal: true

module SlippyTilesScorer
  # TestHelper class to help with testing
  class TestHelper
    class << self
      def stub_tiles_x_y(service:, size: 50)
        service.tiles_x_y = Set.new
        (0...size).each do |i|
          (0...size).each do |j|
            service.tiles_x_y.add([i, j])
          end
        end
        service
      end
    end
  end
end
