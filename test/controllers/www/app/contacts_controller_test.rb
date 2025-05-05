require "test_helper"

class Www::App::ContactsControllerTest < ActionDispatch::IntegrationTest
  teardown do
    # コントローラがキャッシュを使っている場合、テスト後にリセットしておくとよい
    Rails.cache.clear
  end

  test "should get new" do
    get new_www_app_contact_url
    assert_response :success
    assert_select "h1", I18n.t("controller.www.app.contacts.new.page_title")
    assert_select "p", "Find me in app/views/www/app/contacts/new.html.erb"
    assert_select "form[action=?][method=?]", www_app_contacts_path, "post" do
      assert_select "input[type=?][name=?]", "checkbox", "service_site_contact[confirm_policy]"
      assert_select "input[type=?][name=?]", "hidden", "service_site_contact[confirm_policy]"
      assert_select "label[for=?]", "service_site_contact_email_address"
      assert_select "label[for=?]", "service_site_contact_confirm_policy", I18n.t("controller.www.app.contacts.new.confirm_policy")
      assert_select "label[for=?]", "service_site_contact_telephone_number"
      assert_select "input[type=?][name=?]", "text", "service_site_contact[telephone_number]"
      assert_select "div.cf-turnstile", 1
      assert_select "input[type=?]", "submit"
    end
    assert_nil session[:contact_id]
    assert_nil session[:contact_email_address]
    assert_nil session[:contact_telephone_number]
  end

  test "should get create" do
    email_address = "sample@example.com"
    telephone_number = "+819012345678"
    assert_no_difference("ServiceSiteContact.count") do
      post www_app_contacts_url, params: { service_site_contact: {
        confirm_policy: 1,
        email_address: email_address,
        telephone_number: telephone_number }
      }
    end
    assert session[:contact_id]
    assert_equal email_address, session[:contact_email_address]
    assert_equal telephone_number, session[:contact_telephone_number]
    assert_redirected_to new_www_app_contact_email_url(session[:contact_id])
  end

  test "should not get create" do
    email_address = "sample@example.net"
    telephone_number = "+819012345670"
    assert_no_difference("ServiceSiteContact.count") do
      post www_app_contacts_url, params: { service_site_contact: {
        confirm_policy: 0,
        email_address: email_address,
        telephone_number: telephone_number }
      }
    end
    assert_not session[:contact_id]
    assert_nil session[:contact_email_address]
    assert_nil session[:contact_telephone_number]
  end

  # test "should get update" do
  #   get www_app_contacts_url(1)
  #   assert_response :success
  # end
  #
  # test "should get edit" do
  #   get edit_www_app_contact_url(1)
  #   assert_response :success
  # end
end
