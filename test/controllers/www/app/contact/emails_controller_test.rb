require "test_helper"

class Www::App::Contact::EmailsControllerTest < ActionDispatch::IntegrationTest
  teardown do
    Rails.cache.clear
  end

  # FIXME: rewrite code
  # test "should not get new email contact when invalid way" do
  #   get new_www_app_contact_email_url(1)
  #   refute session[:contact_id]
  #   refute session[:contact_email_checked]
  #   refute session[:contact_telephone_checked]
  #   refute session[:contact_expires_in]
  #   assert_response :unprocessable_entity
  # end
end
