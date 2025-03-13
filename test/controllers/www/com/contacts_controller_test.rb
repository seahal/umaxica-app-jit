require "test_helper"

class Com::ContactsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_com_contact_url
    assert_response :success
  end
end
