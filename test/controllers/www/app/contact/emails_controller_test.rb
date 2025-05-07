require "test_helper"

class Www::App::Contact::EmailsControllerTest < ActionDispatch::IntegrationTest
  teardown do
    Rails.cache.clear
  end

  test "should get new" do
    get new_www_app_contact_email_url(0)
    # assert_response  :unprocessable_entity
  end
end
