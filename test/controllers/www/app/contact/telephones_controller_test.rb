require "test_helper"

class Www::App::Contact::TelephonesControllerTest < ActionDispatch::IntegrationTest
  teardown do
    Rails.cache.clear
  end

  # FIXME: rewrite code
  # test "should not get new telephone contact when invalid way" do
  #     get new_www_app_contact_telephone_url(2)
  #     refute session[:contact_id]
  #     refute session[:contact_email_checked]
  #     refute session[:contact_telephone_checked]
  #     refute session[:contact_expires_in]
  #     assert_response :unprocessable_entity
  # end
end
