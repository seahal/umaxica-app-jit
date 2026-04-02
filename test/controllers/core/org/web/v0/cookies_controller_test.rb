# typed: false
# frozen_string_literal: true

require "test_helper"

class Core::Org::Web::V0::CookiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV.fetch("MAIN_STAFF_URL", "main.org.localhost")
    host! @host
  end

  test "GET show without access jwt returns consented false" do
    cookies.delete(Preference::CookieName.access)

    get main_org_web_v0_cookie_path, as: :json

    assert_response :ok
    body = response.parsed_body

    assert_not body["consented"]
    assert_not body["functional"]
    assert_not body["performant"]
    assert_not body["targetable"]
  end
end
