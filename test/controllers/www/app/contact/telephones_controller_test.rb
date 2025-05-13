require "test_helper"

class Www::App::Contact::TelephonesControllerTest < ActionDispatch::IntegrationTest
  teardown do
    Rails.cache.clear
  end

  # FIXME: rewrite code
  test "should not get new telephone contact when invalid way" do
    assert_raise do
      get new_www_app_contact_telephone_url(2)
    end
  end
end
