# SlippyTilesScorer

> [!NOTE]\
> This gem's API is not considered stable yet. Things might change in the
> future.

[![Gem Version](https://badge.fury.io/rb/slippy_tiles_scorer.svg)](https://badge.fury.io/rb/slippy_tiles_scorer)\
![Coverage](https://github.com/simonneutert/slippy_tiles_scorer/blob/main/coverage_badge.svg)\
[![Ruby](https://github.com/simonneutert/slippy_tiles_scorer/actions/workflows/main.yml/badge.svg)](https://github.com/simonneutert/slippy_tiles_scorer/actions/workflows/main.yml)

Calculate scores of map tiles (x, y) on a map. The scores are total, (max)
clusters, and max squares.

To experiment with that code, run `bin/console` for an interactive prompt.

Supports Ruby >= 3.0, JRuby >= 9.4 and latest TruffleRuby (with GraalVM).

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add slippy_tiles_scorer
```

If bundler is not being used to manage dependencies, install the gem by
executing:

```bash
gem install slippy_tiles_scorer
```

## Usage

Find some examples below.

### Simple

A simple example of how to use the `TileScorer` class, when tinkering in a REPL.

```ruby
require 'slippy_tiles_scorer'

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
    #           [
    #             [0, 0], [1, 0], [0, 1], [1, 1], [0, 2], [1, 2], [2, 2], [2, 1], [2, 0]
    #           ]
    #       ],
    #       :cluster_tiles=>#<Set: {[1, 1]}>,
    #       :clusters_of_cluster_tiles=>[[[1, 1]]]
    #   }

# calculate max squares
tile_scorer.max_squares # => {:size=>0, top_left_tile_x_y=>#<Set: {[0, 0]}>}
tile_scorer.max_squares(min_size: 4) # => {:size=>0, top_left_tile_x_y=>#<Set: {}>}
```

### Optimized

An more computationally optimized example of how to use the `TileScorer` class,
when using the code in production.

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

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake test` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and the created tag, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/simonneutert/slippy_tiles_scorer.

## Release new Gem version

To release a new version of the gem, follow these steps:

### Pre-release

1. Make sure the tests pass and coverage badge is updated: `$ bundle exec rake`.
2. Update the version number in `lib/slippy_tiles_scorer/version.rb`.
3. Run `$ bundle install`.
4. Check the `README.md` for correctness.
5. Make sure the `CHANGELOG.md` is up to date.
6. All changes are committed and pushed to the main branch.

### Release

1. Checkout the main branch: `$ git checkout main`.
2. Run the tests: `$ bundle exec rake` (just for safety).
3. Run `$ bundle exec rake release`.

### Post-release

Still being on the main branch:

1. Update the version number in `lib/slippy_tiles_scorer/version.rb` to the next
   development version.
2. Run `$ bundle install`.
3. Commit the changes: `$ git commit -am "Bump version to vX.Y.Z"`.
4. Push the changes: `$ git push`.
