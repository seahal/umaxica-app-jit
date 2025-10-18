# test/test_helper.rb

if ENV["RAILS_ENV"] == "test"
  require "simplecov"
  SimpleCov.start "rails"
end

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

Rails.root.glob("test/support/**/*.rb").sort.each { |file| require file }

module ActiveSupport
  class TestCase
    # parallelize(workers: :number_of_processors)

    fixtures :all
  end
end

class ActionDispatch::IntegrationTest
  include HealthEndpointAssertions

  private

  def default_url_query
    { ri: "jp", tz: "jst", lx: "ja" }
  end
end
