# test/test_helper.rb

# Disable debugger socket in CI sandboxes that set RUBY_DEBUG_OPEN by default.
ENV.delete("RUBY_DEBUG_OPEN")

if ENV["RAILS_ENV"] == "test"
  require "simplecov"
  SimpleCov.minimum_coverage 65
  SimpleCov.start "rails"
end

ENV["REGION_CODE"] ||= "jp"
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # parallelize(workers: :number_of_processors)

    fixtures :all
    set_fixture_class user_identity_passkeys: UserIdentityPasskey,
                      staff_identity_passkeys: StaffIdentityPasskey

    def brand_name
      (ENV["BRAND_NAME"].presence || ENV["NAME"]).to_s
    end
  end
end

module ResponseAssertions
  def assert_unhealthy_response_includes(message)
    assert_response :unprocessable_entity
    body = response.parsed_body

    assert_equal "UNHEALTHY", body["status"]
    assert_includes Array(body["errors"]), message
  end
end

ActiveSupport.on_load(:action_dispatch_integration_test) { include ResponseAssertions }
