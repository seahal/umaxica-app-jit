# typed: false
# frozen_string_literal: true

require "test_helper"

# This test ensures all views use properly defined helpers
# Run this after refactoring to catch missing helper definitions
class CoreViewHelperIntegrityTest < ActionDispatch::IntegrationTest
  test "title helper is available in core views" do
    # Verify that views can use title() helper
    # This would fail if ApplicationHelper doesn't define title method
    host! ENV.fetch("MAIN_CORPORATE_URL", "main.com.localhost")

    get new_main_com_contact_url

    assert_response :success
    # If title helper is missing, view would raise exception
  end

  test "get_language helper is available in core layouts" do
    # Verify get_language is defined and returns expected value
    host! ENV.fetch("MAIN_SERVICE_URL", "main.app.localhost")

    get main_app_root_url

    assert_response :success
    # Check that HTML lang attribute is set (requires get_language helper)
    assert_match(/<html[^>]*lang=/, response.body)
  end

  test "core layouts load without errors" do
    %w(app com org).each do |domain|
      env_var = "MAIN_#{domain.upcase}_URL"
      default_host = "ww.#{domain}.localhost"
      host! ENV.fetch(env_var, default_host)

      root_path = send("main_#{domain}_root_path")
      get root_path

      assert_response :success,
                      "Core #{domain.upcase} layout should render without errors"
    end
  end

  test "contact forms render all required helpers" do
    host! ENV.fetch("MAIN_SERVICE_URL", "main.app.localhost")
    get new_main_app_contact_url

    assert_response :success
    # Verify form uses proper URL helpers
    assert_select "form[action=?]", main_app_contacts_path
  end
end
