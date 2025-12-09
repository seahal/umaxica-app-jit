# test/test_helper.rb

# Disable debugger socket in CI sandboxes that set RUBY_DEBUG_OPEN by default.
ENV.delete("RUBY_DEBUG_OPEN")

if ENV["SKIP_SIMPLECOV"].blank?
  if ENV["RAILS_ENV"] == "test"
    require "simplecov"
    SimpleCov.minimum_coverage 70
    SimpleCov.start "rails"
  end
end

ENV["REGION_CODE"] ||= "jp"
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # parallelize(workers: :number_of_processors)

    fixtures :all

    def brand_name
      (ENV["BRAND_NAME"].presence).to_s
    end
  end
end
