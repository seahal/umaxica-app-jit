# typed: false
# frozen_string_literal: true

require "test_helper"

class ApplicationControllerTest < ActiveSupport::TestCase
  test "uses header_or_legacy_token csrf verification" do
    assert_equal :header_or_legacy_token, ApplicationController.forgery_protection_verification_strategy
  end

  test "uses no trusted origins by default" do
    assert_empty ApplicationController.forgery_protection_trusted_origins
  end

  test "uses env-backed trusted origins on surface controllers" do
    assert_equal %w(http://app.localhost https://app.localhost), Acme::App::ApplicationController.forgery_protection_trusted_origins
    assert_equal %w(http://com.localhost https://com.localhost), Acme::Com::ApplicationController.forgery_protection_trusted_origins
    assert_equal %w(http://org.localhost https://org.localhost), Acme::Org::ApplicationController.forgery_protection_trusted_origins
    assert_equal %w(http://app.localhost https://app.localhost), Base::App::ApplicationController.forgery_protection_trusted_origins
    assert_equal %w(http://com.localhost https://com.localhost), Base::Com::ApplicationController.forgery_protection_trusted_origins
    assert_equal %w(http://org.localhost https://org.localhost), Base::Org::ApplicationController.forgery_protection_trusted_origins
    assert_equal %w(http://docs.app.localhost https://docs.app.localhost), Post::App::ApplicationController.forgery_protection_trusted_origins
    assert_equal %w(http://docs.com.localhost https://docs.com.localhost), Post::Com::ApplicationController.forgery_protection_trusted_origins
    assert_equal %w(http://docs.org.localhost https://docs.org.localhost), Post::Org::ApplicationController.forgery_protection_trusted_origins
  end
end
