# test/test_helper.rb

if ENV["RAILS_ENV"] == "test"
  require "simplecov"
  SimpleCov.start "rails"
end

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"


module ActiveSupport
  class TestCase
    # parallelize(workers: :number_of_processors)

    fixtures :all

    def brand_name
      (ENV["BRAND_NAME"].presence || ENV["NAME"]).to_s
    end
  end
end
