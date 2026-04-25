# typed: false
# frozen_string_literal: true

module Jit
  module Foundation
    require "test_helper"

    class Jit::Foundation::Base::Org::Web::V0::CookiesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @host = ENV.fetch("FOUNDATION_BASE_ORG_URL", "base.org.localhost")
        host! @host
      end

      test "GET show without access jwt returns consented false" do
        cookies.delete(Preference::CookieName.access)

        get foundation.base_org_web_v0_cookie_path, as: :json

        assert_response :ok
        body = response.parsed_body

        assert_not body["consented"]
        assert_not body["functional"]
        assert_not body["performant"]
        assert_not body["targetable"]
      end
    end
  end
end
