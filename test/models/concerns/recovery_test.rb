# frozen_string_literal: true

require "test_helper"

class RecoveryTest < ActiveSupport::TestCase
  class TestUser
    include Recovery
  end

  test "can be included" do
    assert_includes TestUser.ancestors, Recovery
  end
end
