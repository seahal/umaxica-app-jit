# frozen_string_literal: true

require "test_helper"

class Peak::Org::Preference::ResetsControllerTest < ActionDispatch::IntegrationTest
  test "should destroy and redirect" do
    delete peak_org_preference_reset_url

    assert_response :redirect
    assert_match %r{/preference}, response.location
  end
end
