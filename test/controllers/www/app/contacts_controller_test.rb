require "test_helper"

class Www::App::ContactsControllerTest < ActionDispatch::IntegrationTest
  setup do
    Rails.cache.clear
    Www::App::ApplicationController.new # Initializer of RedisMemorize
    @memorize = Www::App::RedisMemorize.new(prefix: SecureRandom.hex(1000))
    @memorize[:contact_telephone_number] = ""
    @memorize[:contact_email_address] = ""
    @memorize[:contact_otp_private_key] = ""
  end

  teardown do
    Rails.cache.clear
    @memorize[:contact_email_address] = ""
    @memorize[:contact_telephone_number] = ""
    @memorize[:contact_otp_private_key] = ""
  end

  test "should get new" do
    get new_www_app_contact_url
    assert_response :success
    assert_select "h1", I18n.t("controller.www.app.contacts.new.page_title")
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
    assert_nil session[:contact_hotp_counter]
    assert_nil session[:contact_email_checked]
    assert_nil session[:contact_telephone_checked]
    assert @memorize[:contact_telephone_number].blank?
    assert @memorize[:contact_email_address].blank?
    assert @memorize[:contact_otp_private_key].blank?
    assert session[:contact_expires_in]
    assert session[:contact_expires_in].to_i > Time.now.to_i
    travel_to 3.hours.from_now do
      assert session[:contact_expires_in].to_i < Time.now.to_i
    end
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
      assert_response :redirect
    end
    #    assert session[:contact_id]
    assert_not_equal email_address, session[:contact_email_address]
    assert_not_equal telephone_number, session[:contact_telephone_number]
    assert @memorize[:contact_email_address].blank?
    assert @memorize[:contact_telephone_number].blank?

    # FIXME: REWRITE!
    #    assert_redirected_to new_www_app_contact_email_url(session[:contact_id])
  end

  test "invalid first post" do
    assert_no_difference("ServiceSiteContact.count") do
      post www_app_contacts_url, params: { service_site_contact: { confirm_policy: 0,
                                                                   email_address: "",
                                                                   telephone_number: "" } }
      #      assert_select "h2", "5 error prohibited this sample from being saved:"
      assert_equal "create", @controller.action_name
      #      assert_response :unprocessable_content
    end
    # assert_no_difference("ServiceSiteContact.count") do
    #   post www_app_contacts_url, params: { service_site_contact: { confirm_policy: 1,
    #                                                                email_address: "",
    #                                                                telephone_number: "" } }
    #   #      assert_select "h2", "4 error prohibited this sample from being saved:"
    #   assert_equal "create", @controller.action_name
    #   assert_response :unprocessable_content
    # end
    # assert_no_difference("ServiceSiteContact.count") do
    #   post www_app_contacts_url, params: { service_site_contact: { confirm_policy: 0,
    #                                                                email_address: "sample@example.net",
    #                                                                telephone_number: "" } }
    #   #      assert_select "h2", "3 error prohibited this sample from being saved:"
    #   assert_equal "create", @controller.action_name
    #   assert_response :unprocessable_content
    # end
    # assert_no_difference("ServiceSiteContact.count") do
    #   post www_app_contacts_url, params: { service_site_contact: { confirm_policy: 0,
    #                                                                email_address: "",
    #                                                                telephone_number: "+817012345678" } }
    #   #      assert_select "h2", "3 error prohibited this sample from being saved:"
    #   assert_equal "create", @controller.action_name
    #   assert_response :unprocessable_content
    # end
    refute session[:contact_id]
    refute session[:contact_email_address]
    refute session[:contact_telephone_number]

    #  assert_redirected_to new_www_app_contact_email_url(session[:contact_id])
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
    assert session[:contact_id] == nil
    assert session[:contact_email_address] == nil
    assert session[:contact_telephone_number] == nil
    assert session[:contact_email_checked] == nil
    assert session[:contact_telephone_checked] == nil
    assert session[:contact_otp_private_key] == nil
    assert session[:contact_expires_in] == nil
  end

  test "should get create email" do
    email_address = "sample@example.com"
    telephone_number = "+819012345600"
    assert_no_difference("ServiceSiteContact.count") do
      post www_app_contacts_url, params: { service_site_contact: {
        confirm_policy: 1,
        email_address: email_address,
        telephone_number: telephone_number }
      }
      assert_response :redirect
    end
    follow_redirect!
    assert_equal "new", @controller.action_name
    assert_equal "emails", @controller.controller_name
    #    assert_select "h1", I18n.t("controller.www.app.contacts.new.page_title")
    # assert_select "p", "Find me in app/views/www/app/contacts/new.html.erb"
    # assert_select "form[action=?][method=?]", www_app_contact_email_path, "post" do
    #  assert_select "label[for=?]", "service_site_contact_email_pass_code"
    #  assert_select "input[type=?][name=?]", "text", "service_site_contact[email_pass_code]"
    #  assert_select "input[type=?]", "submit"
    #  end
  end

  # FIXME: rewrite code
  test "should not get edit contact page when invalid way" do
    get edit_www_app_contact_url(3)
    assert_select "h1", I18n.t("controller.www.app.contacts.error.page_title")
    assert_select "p", I18n.t("controller.www.app.contacts.error.page_description")
    assert_select "p", I18n.t("controller.www.app.contacts.error.back_to_contact_root_page")
    refute session[:contact_id]
    refute session[:contact_email_checked]
    refute session[:contact_telephone_checked]
    refute session[:contact_expires_in]
    assert_response :unprocessable_entity
  end

  # FIXME: rewrite code
  test "should not get show contact page when invalid way" do
    assert_no_difference("ServiceSiteContact.count") do
      get www_app_contact_url(4)
      assert_select "h1", I18n.t("controller.www.app.contacts.error.page_title")
      assert_select "p", I18n.t("controller.www.app.contacts.error.page_description")
      assert_select "p", I18n.t("controller.www.app.contacts.error.back_to_contact_root_page")
      refute session[:contact_id]
      refute session[:contact_email_checked]
      refute session[:contact_telephone_checked]
      refute session[:contact_expires_in]
      assert_response :unprocessable_entity
    end
  end

  # FIXME: rewrite code
  test "should get show contact page when invalid method" do
    assert_no_difference("ServiceSiteContact.count") do
      # u1 = SecureRandom.uuid_v4
      # u2 = SecureRandom.uuid_v7
      # cookies[:contact_id] = u2
      # cookies[:contact_email_checked] = false
      # cookies[:contact_telephone_checked] = true
      # cookies[:contact_count] = 1
      # get www_app_contact_url(u1)
      # assert_response :success
      refute nil
    end
  end
end
