require "test_helper"

class Www::App::Session::EmailsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_www_app_authentication_email_url
    assert_select "h1", I18n.t("www.app.authentication.email.new.page_title")
    assert_select "ul li" do
      assert_select "a", I18n.t("www.app.authentication.new.back")
      assert_select "a", I18n.t("www.app.authentication.email.new.registration")
    end
    assert_select "a[href=?]", new_www_app_authentication_path
    assert_select "form[action=?][method=?]", www_app_authentication_email_path, "post" do
      # email入力フィールドの存在と属性チェック
      assert_select "input[type=?][name=?]", "email", "user_email[address]"
      # cloudflare tunstile
      assert_select "div.cf-turnstile"
      # submitボタンの存在
      assert_select "input[type=?]", "submit"
    end
    assert_not cookies[:htop_private_key].nil?
    assert_select "a[href=?]", new_www_app_authentication_path, I18n.t('www.app.authentication.new.back')
    assert_response :success
  end

  # FIXME: implement this test
  test "reject already logged in user" do
    get new_www_app_authentication_email_url
    assert_response :success
  end

  # FIXME: implement this test
  test "reject already logged in staff" do
    get new_www_app_authentication_email_url
    assert_response :success
  end
end
