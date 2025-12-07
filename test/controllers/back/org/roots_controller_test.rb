# frozen_string_literal: true

require "test_helper"

module Back::Org
  class RootsControllerTest < ActionDispatch::IntegrationTest
    BACK_STAFF_URL = ENV.fetch("BACK_STAFF_URL", "back-staff.example.com")

    test "should redirect to BACK_STAFF_URL" do
      get back_org_root_url

      assert_response :success
    end
  end
end
