# typed: false
# frozen_string_literal: true

require "test_helper"

class SocialCallbackGuardIncludedDoTest < ActiveSupport::TestCase
  test "verify_social_callback_request! method exists (private)" do
    assert_includes SocialCallbackGuard.private_instance_methods(false), :verify_social_callback_request!
  end

  test "REQUEST_PHASE_PATH constant is defined" do
    assert_kind_of Regexp, SocialCallbackGuard::REQUEST_PHASE_PATH
  end
end
