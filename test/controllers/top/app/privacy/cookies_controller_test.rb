require "test_helper"


class Top::App::Privacy::CookiesControllerTest < ActionDispatch::IntegrationTest
  # rubocop:disable Minitest/MultipleAssertions
  test "should get edit" do
    original_forgery_setting = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true

    get edit_top_app_privacy_cookie_url

    assert_response :success
    assert_select "h1", I18n.t("top.app.preference.cookie.edit.h1")
    expected_action = top_app_privacy_cookie_url(ri: "jp", tz: "jst", lx: "ja")
    assert_select "form[action=?]", expected_action do
      assert_select "input[type='hidden'][name='authenticity_token']", count: 1
      assert_select "input[type='checkbox'][name='accept_tracking_cookies']", count: 0
      assert_select "input[type='checkbox'][name='accept_necessary_cookies']", count: 1
      assert_select "input[type='checkbox'][name='accept_targeting_cookies']", count: 1
      assert_select "input[type='checkbox'][name='accept_functional_cookies']", count: 1
      assert_select "input[type='checkbox'][name='accept_performance_cookies']", count: 1
      assert_select "input[type='checkbox'][name='accept_tracking_cookies'][checked]", count: 0
      assert_select "label", I18n.t("top.app.preference.cookie.edit.accept_necessary_cookies")
      assert_select "label", I18n.t("top.app.preference.cookie.edit.accept_targeting_cookies")
      assert_select "label", I18n.t("top.app.preference.cookie.edit.accept_functional_cookies")
      assert_select "label", I18n.t("top.app.preference.cookie.edit.accept_performance_cookies")
      assert_select "input[type='submit']", count: 1
    end
    assert_select "a[href^='#{top_app_preference_path}']", text: I18n.t("top.app.preferences.back_to_settings")
  ensure
    ActionController::Base.allow_forgery_protection = original_forgery_setting
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "submitting the form toggles the checkboxes via persisted preferences" do
    original_forgery_setting = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = false

    get edit_top_app_privacy_cookie_url

    assert_select "input[type='checkbox'][name='accept_functional_cookies'][checked]", count: 0
    assert_select "input[type='checkbox'][name='accept_performance_cookies'][checked]", count: 0
    assert_select "input[type='checkbox'][name='accept_targeting_cookies'][checked]", count: 0

    patch top_app_privacy_cookie_url,
          params: {
            accept_functional_cookies: "1",
            accept_performance_cookies: "1",
            accept_targeting_cookies: "1"
          }
    follow_redirect!

    assert_response :success
    assert_select "input[type='checkbox'][name='accept_functional_cookies'][checked]", count: 1
    assert_select "input[type='checkbox'][name='accept_performance_cookies'][checked]", count: 1
    assert_select "input[type='checkbox'][name='accept_targeting_cookies'][checked]", count: 1

    assert_select "a[href^='#{top_app_preference_path}']", text: I18n.t("top.app.preferences.back_to_settings")

    patch top_app_privacy_cookie_url,
          params: {
            accept_functional_cookies: "0",
            accept_performance_cookies: "0",
            accept_targeting_cookies: "0"
          }
    follow_redirect!

    assert_response :success
    assert_select "input[type='checkbox'][name='accept_functional_cookies'][checked]", count: 0
    assert_select "input[type='checkbox'][name='accept_performance_cookies'][checked]", count: 0
    assert_select "input[type='checkbox'][name='accept_targeting_cookies'][checked]", count: 0
    assert_select "a[href^='#{top_app_preference_path}']", text: I18n.t("top.app.preferences.back_to_settings")
  ensure
    ActionController::Base.allow_forgery_protection = original_forgery_setting
  end
  # rubocop:enable Minitest/MultipleAssertions
end
