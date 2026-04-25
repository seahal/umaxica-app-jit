# typed: false
# frozen_string_literal: true

require "test_helper"

module VerificationCookieable
  class VerificationCookieableTest < ActiveSupport::TestCase
    test "cookie_name returns verification in non-production" do
      Rails.stub(:env, ActiveSupport::StringInquirer.new("development")) do
        assert_equal "verification", VerificationCookieable.cookie_name
      end
    end

    test "cookie_name returns __Secure-verification in production" do
      Rails.stub(:env, ActiveSupport::StringInquirer.new("production")) do
        assert_equal "__Secure-verification", VerificationCookieable.cookie_name
      end
    end

    test "cookie_name returns verification in test" do
      Rails.stub(:env, ActiveSupport::StringInquirer.new("test")) do
        assert_equal "verification", VerificationCookieable.cookie_name
      end
    end

    test "COOKIE_BASENAME is verification" do
      assert_equal "verification", VerificationCookieable::COOKIE_BASENAME
    end

    test "SECURE_COOKIE_PREFIX is __Secure-" do
      assert_equal "__Secure-", VerificationCookieable::SECURE_COOKIE_PREFIX
    end
  end
end
