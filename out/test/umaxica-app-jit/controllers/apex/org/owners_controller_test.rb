require "test_helper"

class Apex::Org::OwnersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get apex_org_owners_url
    assert_response :success
  end

  test "should get new" do
    get new_apex_org_owner_url
    assert_response :success
  end

  test "should create owner" do
    assert_difference("Owner.count", 1) do
      post apex_org_owners_url, params: { owner: { name: "Test Owner" } }
    end
    assert_redirected_to apex_org_owner_url(Owner.last)
  end

  test "should show owner" do
    owner = owners(:one)
    get apex_org_owner_url(owner)
    assert_response :success
  end

  test "should get edit" do
    owner = owners(:one)
    get edit_apex_org_owner_url(owner)
    assert_response :success
  end

  test "should update owner" do
    owner = owners(:one)
    patch apex_org_owner_url(owner), params: { owner: { name: "Updated Name" } }
    assert_redirected_to apex_org_owner_url(owner)
  end

  test "should destroy owner" do
    owner = owners(:one)
    assert_difference("Owner.count", -1) do
      delete apex_org_owner_url(owner)
    end
    assert_redirected_to apex_org_owners_url
  end
end
