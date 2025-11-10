# frozen_string_literal: true

require "test_helper"

class Bff::Org::Preference::EmailsControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get edit_bff_org_preference_email_url(id: 1)

    assert_response :success
  end

  test "edit page should render form with email preference fields" do
    get edit_bff_org_preference_email_url(id: 1)

    assert_response :success
    assert_select "h1"
    assert_select "form[method='post']" do
      assert_select "input[name='_method'][value='patch']", count: 1
      assert_select "input[type='checkbox'][name='enabled']"
      assert_select "input[type='submit']"
    end
  end

  test "should update and redirect with success message" do
    patch bff_org_preference_email_url(id: 1), params: { enabled: true }

    assert_response :redirect
    assert_match %r{/preference}, response.location
  end

  test "should update with enabled false" do
    patch bff_org_preference_email_url(id: 1), params: { enabled: false }

    assert_response :redirect
    assert_match %r{/preference}, response.location
  end

  test "should handle update without parameters" do
    patch bff_org_preference_email_url(id: 1)

    assert_response :redirect
  end
end
