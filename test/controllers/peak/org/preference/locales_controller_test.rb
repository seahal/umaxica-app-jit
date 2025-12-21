# frozen_string_literal: true

require "test_helper"

module Peak::Org::Preference
  class LocalesControllerTest < ActionDispatch::IntegrationTest
    test "should include PreferenceLocales concern" do
      assert_includes LocalesController.included_modules, PreferenceLocales
    end

    # test "should get edit" do
    #   get edit_peak_org_preference_locale_url
    #
    #   assert_response :success
    # end
  end
end
