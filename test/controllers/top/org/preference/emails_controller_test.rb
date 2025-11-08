# frozen_string_literal: true

require "test_helper"

class Top::Org::Preference::EmailsControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get edit_top_org_preference_email_url(id: 1)

    assert_response :success
  end

  test "should update and redirect" do
    patch top_org_preference_email_url(id: 1), params: { enabled: true }

    assert_response :redirect
    assert_match %r{/preference}, response.location
  end
end
