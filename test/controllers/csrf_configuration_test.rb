# typed: false
# frozen_string_literal: true

require "test_helper"

class CsrfConfigurationTest < ActiveSupport::TestCase
  test "all application controllers use header_or_legacy_token with explicit trusted origins" do
    expected_trusted_origins.each do |controller_class, trusted_origins|
      assert_equal :header_or_legacy_token, controller_class.forgery_protection_verification_strategy
      assert_equal trusted_origins, controller_class.forgery_protection_trusted_origins
    end
  end

  private

  def expected_trusted_origins
    {
      ApplicationController => %w(
        http://sign.app.localhost
        http://sign.org.localhost
        http://app.localhost
        http://org.localhost
        http://com.localhost
        http://www.app.localhost
        http://www.org.localhost
        http://www.com.localhost
        http://docs.app.localhost
        http://docs.org.localhost
        http://docs.com.localhost
        http://news.app.localhost
        http://news.org.localhost
        http://news.com.localhost
        http://help.app.localhost
        http://help.org.localhost
        http://help.com.localhost
        http://www.example.com
      ),
      Sign::App::ApplicationController => %w(http://sign.app.localhost),
      Sign::Org::ApplicationController => %w(http://sign.org.localhost),
      Apex::App::ApplicationController => %w(http://app.localhost),
      Apex::Org::ApplicationController => %w(http://org.localhost),
      Apex::Com::ApplicationController => %w(http://com.localhost),
      Core::App::ApplicationController => %w(http://app.localhost),
      Core::Org::ApplicationController => %w(http://org.localhost),
      Core::Com::ApplicationController => %w(http://com.localhost),
      Docs::App::ApplicationController => %w(http://docs.app.localhost),
      Docs::Org::ApplicationController => %w(http://docs.org.localhost),
      Docs::Com::ApplicationController => %w(http://docs.com.localhost),
      Help::App::ApplicationController => %w(http://help.app.localhost),
      Help::Org::ApplicationController => %w(http://help.org.localhost),
      Help::Com::ApplicationController => %w(http://help.com.localhost),
      News::App::ApplicationController => %w(http://news.app.localhost),
      News::Org::ApplicationController => %w(http://news.org.localhost),
      News::Com::ApplicationController => %w(http://news.com.localhost),
    }
  end
end
