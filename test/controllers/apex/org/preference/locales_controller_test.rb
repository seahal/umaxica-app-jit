# frozen_string_literal: true

require "test_helper"

module Apex::Org::Preference
  class LocalesControllerTest < ActionDispatch::IntegrationTest
    setup do
      host! ENV.fetch("APEX_STAFF_URL", "org.localhost")
      https!
    end

    test "should include PreferenceLocales concern" do
      assert_includes LocalesController.included_modules, PreferenceLocales
    end

    # test "should get edit" do
    #   get edit_apex_org_preference_locale_url
    #
    #   assert_response :success
    # end
  end
end
