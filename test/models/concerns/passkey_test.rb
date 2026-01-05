# frozen_string_literal: true

require "test_helper"

class PasskeyTest < ActiveSupport::TestCase
  class TestUser
    include Passkey
  end

  test "can be included" do
    assert_includes TestUser.ancestors, Passkey
  end
end
