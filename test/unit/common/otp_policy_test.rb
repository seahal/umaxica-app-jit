# typed: false
# frozen_string_literal: true

require "test_helper"

module Common
  class OtpPolicyTest < ActiveSupport::TestCase
    test "SEND_COOLDOWN is 30 seconds" do
      assert_equal 30.seconds, OtpPolicy::SEND_COOLDOWN
    end

    test "SEND_COOLDOWN is an ActiveSupport::Duration" do
      assert_kind_of ActiveSupport::Duration, OtpPolicy::SEND_COOLDOWN
    end
  end
end
