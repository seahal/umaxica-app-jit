require "test_helper"

class Www::App::Contact::EmailsControllerTest < ActionDispatch::IntegrationTest
  teardown do
    Rails.cache.clear
  end

  # FIXME: rewrite code
  test "should not get new email contact when invalid way" do
    assert_raise do
      get new_www_app_contact_email_url(1)
    end
  end
end
