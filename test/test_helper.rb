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
  end
end

class ActionDispatch::IntegrationTest
  private

  def signed_cookie(name)
    ActionDispatch::Cookies::CookieJar.build(request, cookies.to_hash).signed[name]
  end
end
