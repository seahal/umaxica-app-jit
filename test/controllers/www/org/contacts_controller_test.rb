require "test_helper"

class Www::Org::ContactsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get www_org_contacts_new_url
    assert_response :success
  end

  test "should get show" do
    get www_org_contacts_show_url
    assert_response :success
  end

  test "should get update" do
    get www_org_contacts_update_url
    assert_response :success
  end

  test "should get index" do
    get www_org_contacts_index_url
    assert_response :success
  end

  test "should get edit" do
    get www_org_contacts_edit_url
    assert_response :success
  end
end
