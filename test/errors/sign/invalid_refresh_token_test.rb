# typed: false
# frozen_string_literal: true

require "test_helper"

module Sign
  class InvalidRefreshTokenTest < ActiveSupport::TestCase
    test "is a subclass of StandardError" do
      assert_kind_of StandardError, InvalidRefreshToken.new
    end

    test "can be raised and rescued" do
      assert_raises(InvalidRefreshToken) do
        raise InvalidRefreshToken, "token is invalid"
      end
    end
  end
end
