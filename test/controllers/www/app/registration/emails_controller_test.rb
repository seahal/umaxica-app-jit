require "test_helper"

class Net::Registration::EmailsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_net_registration_email_url
    assert_response :success
    assert_select "a[href=?]", net_root_path, count: 2
  end

  test "should show link for sign in pages" do
    get new_net_registration_email_url
    assert_select "a[href=?]", new_net_session_path, count: 1
  end

  test "DOM validation" do
    get new_net_registration_email_url
    assert_select "input#user_email_address"
    assert_select "input#user_email_confirm_policy"

    assert_select "form[action=?][method=?]", net_registration_email_path, "post" do
      # email入力フィールドの存在と属性チェック
      assert_select "input[type=?][name=?]", "email", "user_email[address]"

      # checkboxの存在と属性チェック
      assert_select "input[type=?][name=?]", "checkbox", "user_email[confirm_policy]"

      # submitボタンの存在
      assert_select "input[type=?]", "submit"
    end
  end
end
