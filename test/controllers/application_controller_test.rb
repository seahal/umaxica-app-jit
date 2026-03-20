# typed: false
# frozen_string_literal: true

require "test_helper"

class ApplicationControllerTest < ActiveSupport::TestCase
  test "uses header_or_legacy_token csrf verification" do
    assert_equal :header_or_legacy_token, ApplicationController.forgery_protection_verification_strategy
  end

  test "builds trusted origins from configured hosts" do
    assert_includes ApplicationController.forgery_protection_trusted_origins, "http://app.localhost"
    assert_includes ApplicationController.forgery_protection_trusted_origins, "https://app.localhost"
    assert_includes ApplicationController.forgery_protection_trusted_origins, "http://www.example.com"
    assert_includes ApplicationController.forgery_protection_trusted_origins, "https://www.example.com"
    assert_not_includes ApplicationController.forgery_protection_trusted_origins, "app.localhost"
  end
end
