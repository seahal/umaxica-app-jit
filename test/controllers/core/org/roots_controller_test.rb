# frozen_string_literal: true

require "test_helper"

module Core::Org
  class RootsControllerTest < ActionDispatch::IntegrationTest
    CORE_STAFF_URL = ENV.fetch("CORE_STAFF_URL", ENV.fetch("BACK_STAFF_URL", "back-staff.example.com"))

    test "should redirect to CORE_STAFF_URL" do
      get core_org_root_url

      assert_response :success
    end

    test "renders layout contract" do
      get core_org_root_url

      assert_response :success
      assert_layout_contract
    end
  end
end
