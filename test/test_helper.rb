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
    fixtures :all
  end
end
