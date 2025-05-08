require "test_helper"

class Www::App::Contact::TelephonesControllerTest < ActionDispatch::IntegrationTest
  teardown do
    Rails.cache.clear
  end

    # FIXME: xxx
#  test "should get new" do
#    get new_www_app_contact_telephone_url(0)
#    assert_response  :unprocessable_entity
#  end
end
