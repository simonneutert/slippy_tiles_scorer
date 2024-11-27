## [Unreleased]

- [#4](https://github.com/simonneutert/slippy_tiles_scorer/pull/4) - Runs a benchmark before running the tests.
- [#3](https://github.com/simonneutert/slippy_tiles_scorer/pull/3) - 100 % test coverage: lines and branches. Adds a badge to the README. Adds gem release notes to the README.

## [0.0.3] - 2024-11-26

- More tests, like a json file with test data.
- The `Rakefile` can be used to run the tests and check the code style.
- A CI pipeline runs the test suite and checks the code style for multiple Ruby
  versions >= v3.
- Rubocop was configured and some plugins were added to the `.rubocop.yml` file.

## [0.0.2] - 2024-11-26

- The result `Hash` of `#clusters` under the key `:clusters` is now an array of
  `[x, y]` and `x` and `y` being integer values.

## [0.0.1] - 2024-11-25

- Initial release
