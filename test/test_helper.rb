# test/test_helper.rb の先頭から
require "simplecov"
SimpleCov.start "rails" do
  enable_coverage :branch
  add_filter %w[/bin/ /db/ /config/ /test/]
  track_files "app/**/*.rb"
end

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)

    # SimpleCov per-worker setup to support Rails parallel testing
    parallelize_setup do |worker|
      SimpleCov.command_name "minitest-worker-#{worker}"
      SimpleCov.coverage_dir File.join(SimpleCov.root, "coverage", "worker-#{worker}")
    end

    parallelize_teardown do |_worker|
      # no-op per worker
    end

    fixtures :all
  end
end

# Collate coverage reports from all workers into a single report
Minitest.after_run do
  resultsets = Dir[File.join(SimpleCov.root, "coverage", "worker-*/.resultset.json")]
  if resultsets.any?
    SimpleCov.collate resultsets do
      enable_coverage :branch
      add_filter %w[/bin/ /db/ /config/ /test/]
      track_files "app/**/*.rb"
    end
  end
end
