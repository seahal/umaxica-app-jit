require "test_helper"

class Peak::Com::Preference::ResetsControllerTest < ActionDispatch::IntegrationTest
  test "should destroy and redirect" do
    delete peak_com_preference_reset_url

    assert_response :redirect
    assert_match %r{/preference}, response.location
  end
end
