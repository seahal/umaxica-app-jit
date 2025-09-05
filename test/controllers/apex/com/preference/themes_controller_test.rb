require "test_helper"

class Apex::Com::Preference::ThemesControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get edit_apex_com_preference_theme_url
    assert_response :success
  end
  #
  # test "should update theme to dark" do
  #   patch apex_com_preference_theme_url, params: { theme: "dark" }
  #   assert_response :redirect
  #   assert_equal "dark", session[:theme]
  #   #    assert_equal "Corporate theme updated to Dark Theme", flash[:notice]
  # end

  test "should update theme to corporate" do
    patch apex_com_preference_theme_url, params: { theme: "corporate" }
    assert_response :redirect
    assert_equal "corporate", session[:theme]
  end

  # test "should update theme to light" do
  #   patch apex_com_preference_theme_url, params: { theme: "light" }
  #   assert_response :redirect
  #   assert_equal "light", session[:theme]
  #    assert_equal "Corporate theme updated to Light Theme", flash[:notice]
  # end

  # test "should reject invalid theme" do
  #   patch apex_com_preference_theme_url, params: { theme: "rainbow" }
  #   assert_response :unprocessable_content
  #   assert_equal "無効なテーマが選択されました", flash[:alert]
  # end
end
