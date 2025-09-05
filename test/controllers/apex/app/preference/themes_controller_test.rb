require "test_helper"

class Apex::App::Preference::ThemesControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get edit_apex_app_preference_theme_url
    assert_response :success
  end

  # test "should update theme with valid theme" do
  #   patch apex_app_preference_theme_url, params: { theme: "dark" }
  #   assert_response :redirect
  #   assert_equal "dark", session[:theme]
  #   assert_equal "テーマをDarkに更新しました", flash[:notice]
  # end

  # test "should update theme to light" do
  #   patch apex_app_preference_theme_url, params: { theme: "light" }
  #   assert_response :redirect
  #   assert_equal "light", session[:theme]
  #   assert_equal "テーマをLightに更新しました", flash[:notice]
  # end
  #
  # test "should update theme to auto" do
  #   patch apex_app_preference_theme_url, params: { theme: "auto" }
  #   assert_response :redirect
  #   assert_equal "auto", session[:theme]
  #   assert_equal "テーマをAutoに更新しました", flash[:notice]
  # end

  # test "should reject invalid theme" do
  #   patch apex_app_preference_theme_url, params: { theme: "rainbow" }
  #   assert_response :unprocessable_content
  #   assert_equal "無効なテーマが選択されました", flash[:alert]
  # end
end
