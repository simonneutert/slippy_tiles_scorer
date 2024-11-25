# frozen_string_literal: true

require_relative "lib/slippy_tiles_scorer/version"

Gem::Specification.new do |spec|
  spec.name = "slippy_tiles_scorer"
  spec.version = SlippyTilesScorer::VERSION
  spec.authors = ["Simon Neutert"]
  spec.email = ["simonneutert@users.noreply.github.com"]

  spec.summary = "A gem to score a set of slippy tiles."
  spec.description = "For a given set of slippy tiles, this gem calculates the score of the tiles, like total tiles, clusters and max squares."
  spec.homepage = "https://github.com/simonneutert/slippy_tiles_scorer"
  spec.required_ruby_version = ">= 3.0.0"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/simonneutert/slippy_tiles_scorer"
  spec.metadata["changelog_uri"] = "https://github.com/simonneutert/slippy_tiles_scorer/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile test-unit.yml test_runner.rb justfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "rubocop", "~> 1.68"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
