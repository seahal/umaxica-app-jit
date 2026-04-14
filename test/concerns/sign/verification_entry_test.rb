# typed: false
# frozen_string_literal: true

require "test_helper"

module Sign
  class VerificationEntryTest < ActiveSupport::TestCase
    test "is a valid concern module" do
      assert_kind_of Module, Sign::VerificationEntry
      assert_kind_of ActiveSupport::Concern, Sign::VerificationEntry
    end

    test "defines show method" do
      assert Sign::VerificationEntry.method_defined?(:show)
    end

    test "defines reauth_session_key method" do
      assert Sign::VerificationEntry.private_method_defined?(:reauth_session_key)
    end

    test "defines verification_success_notice_key method" do
      assert Sign::VerificationEntry.private_method_defined?(:verification_success_notice_key)
    end

    test "defines verification_invalid_request_redirect_path method" do
      assert Sign::VerificationEntry.private_method_defined?(:verification_invalid_request_redirect_path)
    end
  end
end
