# frozen_string_literal: true

require "test_helper"
require_relative "../../../../app/controllers/concerns/authorization/base"

# Ensures Authorization::Base enforces interface methods via exceptions.
class AuthorizationBaseTest < ActiveSupport::TestCase
  test "raises NotImplementedError for active?" do
    dummy = Object.new
    dummy.extend(Authorization::Base)

    error =
      assert_raises(NotImplementedError) do
        dummy.active?
      end
    assert_match(/active\? must be implemented/, error.message)
  end

  test "raises NotImplementedError for am_i_user?" do
    dummy = Object.new
    dummy.extend(Authorization::Base)

    error =
      assert_raises(NotImplementedError) do
        dummy.am_i_user?
      end
    assert_match(/am_i_user\? must be implemented/, error.message)
  end

  test "raises NotImplementedError for am_i_staff?" do
    dummy = Object.new
    dummy.extend(Authorization::Base)

    error =
      assert_raises(NotImplementedError) do
        dummy.am_i_staff?
      end
    assert_match(/am_i_staff\? must be implemented/, error.message)
  end

  test "raises NotImplementedError for am_i_owner?" do
    dummy = Object.new
    dummy.extend(Authorization::Base)

    error =
      assert_raises(NotImplementedError) do
        dummy.am_i_owner?
      end
    assert_match(/am_i_owner\? must be implemented/, error.message)
  end
end
