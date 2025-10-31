require "test_helper"

class Help::Com::ContactsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_help_com_contact_url
    assert_response :success
  end
end
