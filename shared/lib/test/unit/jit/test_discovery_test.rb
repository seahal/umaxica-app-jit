# typed: false
# frozen_string_literal: true

require "test_helper"

class TestDiscoveryTest < ActiveSupport::TestCase
  test "default test glob includes engine test files" do
    tests = Rails::TestUnit::Runner.send(:list_tests, []).to_a

    assert_includes tests, "test/unit/jit/four_engine_split_acceptance_test.rb"
    assert_includes tests, "engines/identity/test/controllers/sign/app/application_controller_test.rb"
    assert_includes tests, "engines/zenith/test/controllers/acme/app/application_controller_test.rb"
    assert_includes tests, "engines/foundation/test/controllers/base/app/application_controller_test.rb"
    assert_includes tests, "engines/distributor/test/controllers/docs/com/application_controller_test.rb"
  end
end
