# typed: false
# frozen_string_literal: true

require "test_helper"

class LayoutMetaTagsTest < ActionDispatch::IntegrationTest
  def setup
    # Map of Namespace => [Host ENV Name, Path]
    @targets = {
      "Apex::Com" => ["APEX_CORPORATE_URL", "/"],
      "Apex::App" => ["APEX_SERVICE_URL", "/"],
      "Apex::Org" => ["APEX_STAFF_URL", "/"],
      "Back::Com" => ["MAIN_CORPORATE_URL", "/"],
      "Back::App" => ["MAIN_SERVICE_URL", "/"],
      "Back::Org" => ["MAIN_STAFF_URL", "/"],
      "Docs::Com" => ["DOCS_CORPORATE_URL", "/"],
      "Docs::App" => ["DOCS_SERVICE_URL", "/"],
      "Docs::Org" => ["DOCS_STAFF_URL", "/"],
      "Sign::App" => ["SIGN_SERVICE_URL", "/"],
      "Sign::Org" => ["SIGN_STAFF_URL", "/"],
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
