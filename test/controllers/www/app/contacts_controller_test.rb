require "test_helper"

class Www::App::ContactsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_www_app_contact_url
   assert_response :success
  end

  test "should get show" do
    get www_app_contacts_url(1)
    assert_response :success
  end
  #
  test "should get update" do
    get www_app_contacts_url(1)
    assert_response :success
  end
  #
  test "should get index" do
    get www_app_contacts_url
    assert_response :success
  end
  #
  test "should get edit" do
    get edit_www_app_contact_url(1)
    assert_response :success
  end
end
