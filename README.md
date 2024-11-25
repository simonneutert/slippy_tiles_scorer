# SlippyTilesScorer

> [!NOTE]  
> This gem's API is not considered stable yet.
> Things might change in the future.

[![Gem Version](https://badge.fury.io/rb/slippy_tiles_scorer.svg)](https://badge.fury.io/rb/slippy_tiles_scorer) \
[![Ruby](https://github.com/simonneutert/slippy_tiles_scorer/actions/workflows/main.yml/badge.svg)](https://github.com/simonneutert/slippy_tiles_scorer/actions/workflows/main.yml)

Calculate scores of map tiles (x, y) on a map. The scores are total, (max)
clusters, and max squares.

To experiment with that code, run `bin/console` for an interactive prompt.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add slippy_tiles_scorer
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install slippy_tiles_scorer
```

## Usage

Find some examples below.

### Simple

A simple example of how to use the `TileScorer` class, when tinkering in a REPL.

```ruby
require 'tile_scorer'

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

tile_scorer = SlippyTilesScorer::Score.new(tiles_x_y: collection_of_tiles)
tile_scorer.valid? # => true

# the collection_of_tiles is a 3x3 map and will be used to calculate scores,
# unless you provide a different set of tiles, when calling the methods.

tile_scorer.visited # => 9

# calculate clusters
tile_scorer.clusters # => 
    #   {
    #       :clusters=>[
    #           <Set: {[0, 0], [1, 0], [0, 1], [1, 1], [0, 2], [1, 2], [2, 2], [2, 1], [2, 0]}>
    #       ],
    #       :cluster_tiles=>#<Set: {[1, 1]}>,
    #       :clusters_of_cluster_tiles=>[]
    #   }

# calculate max squares
tile_scorer.max_squares # => {:size=>3, top_left_tile_x_y=>#<Set: {[0, 0]}>}
tile_scorer.max_squares(min_size: 4) # => {:size=>4, top_left_tile_x_y=>#<Set: {}>}
```

### Optimized

An more computationally optimized example of how to use the `TileScorer` class, when using the code in production.

```ruby
### OPTIMIZE COMPUTATION ###
tile_scorer = SlippyTilesScorer::Score.new(tiles_x_y: collection_of_tiles)
# Optimize computation by calculating clusters first,
result_clusters = tile_scorer.clusters
clusters = result_clusters[:clusters]
# then max squares based on the clusters.
max_squares_of_clusters = clusters.flat_map do |cluster|
  tile_scorer.max_squares(tiles_x_y: cluster)
end
# Find the max squares with the biggest edge size.
max_squares_max_size_mapped = max_squares_of_clusters.map do |max_square| 
  max_square[:size]
end
max_squares_max_size = max_squares_max_size_mapped.max
# Select and keep only the max squares with the biggest edge size.
max_squares = max_squares_of_clusters.select do |max_square|
  max_square[:size] == max_squares_max_size
end
puts max_squares # =>[{:size=>3, top_left_tile_x_y=>#<Set: {[0, 0]}>}]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/simonneutert/slippy_tiles_scorer.
