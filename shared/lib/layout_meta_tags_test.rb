# typed: false
# frozen_string_literal: true

require "test_helper"

class LayoutMetaTagsTest < ActionDispatch::IntegrationTest
  def setup
    # Map of Namespace => [Host ENV Name, Path]
    @targets = {
      "Acme::Com" => ["ZENITH_ACME_COM_URL", "/"],
      "Acme::App" => ["ZENITH_ACME_APP_URL", "/"],
      "Acme::Org" => ["ZENITH_ACME_ORG_URL", "/"],
      "Back::Com" => ["FOUNDATION_BASE_COM_URL", "/"],
      "Back::App" => ["FOUNDATION_BASE_APP_URL", "/"],
      "Back::Org" => ["FOUNDATION_BASE_ORG_URL", "/"],
      "Post::Com" => ["DISTRIBUTOR_POST_COM_URL", "/"],
      "Post::App" => ["DISTRIBUTOR_POST_APP_URL", "/"],
      "Post::Org" => ["DISTRIBUTOR_POST_ORG_URL", "/"],
      "Sign::App" => ["IDENTITY_SIGN_APP_URL", "/"],
      "Sign::Org" => ["IDENTITY_SIGN_ORG_URL", "/"],
    }
  end

  test "all layouts include turbo-refresh-scroll meta tag" do
    @targets.each do |name, (env_key, path)|
      host = ENV[env_key]
      next if host.blank?

      host! host
      get path

      if response.redirect?
        follow_redirect!
      end

      assert_response :success, "Failed to access #{path} for #{name} (#{host})"
      assert_select "meta[name='turbo-refresh-scroll'][content='preserve']", 1,
                    "Expected turbo-refresh-scroll meta tag in #{name} layout"
    end
  end

  test "all layouts include title tag" do
    @targets.each do |name, (env_key, path)|
      host = ENV[env_key]
      next if host.blank?

      host! host
      get path

      if response.redirect?
        follow_redirect!
      end

      assert_response :success, "Failed to access #{path} for #{name} (#{host})"
      assert_select "title", { count: 1 }, "Expected exactly one title tag in #{name} layout"
    end
  end
end
