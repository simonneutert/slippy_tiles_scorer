# frozen_string_literal: true

require "set"
require "json"
require "test/unit"
require_relative "test_helper"

require_relative "lib/slippy_tiles_scorer"
require_relative "lib/slippy_tiles_scorer/cluster"
require_relative "lib/slippy_tiles_scorer/max_square"

Dir.glob("./test/**/test_*.rb").each do |path|
  require_relative File.expand_path(path)
end
