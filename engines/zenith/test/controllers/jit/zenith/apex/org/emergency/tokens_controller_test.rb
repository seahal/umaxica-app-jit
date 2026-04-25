# typed: false
# frozen_string_literal: true

module Jit
  module Zenith
    require "test_helper"

    class Jit::Zenith::Acme::Org::Emergency::TokensControllerTest < ActionDispatch::IntegrationTest
      setup do
        host! ENV.fetch("ZENITH_ACME_ORG_URL", "org.localhost")
      end

      test "routes emergency app/com token to acme org controllers" do
        get "http://#{ENV.fetch("ZENITH_ACME_ORG_URL", "org.localhost")}/emergency/app/token"

        assert_equal "acme/org/emergency/app/tokens", request.path_parameters[:controller]
        assert_equal "show", request.path_parameters[:action]

        get "http://#{ENV.fetch("ZENITH_ACME_ORG_URL", "org.localhost")}/emergency/com/token"

        assert_equal "acme/org/emergency/com/tokens", request.path_parameters[:controller]
        assert_equal "show", request.path_parameters[:action]
      end

      test "GET show returns success" do
        get zenith.acme_org_emergency_app_token_url

        assert_response :success
        assert_select "h1", "Emergency Org App Token"

        get zenith.acme_org_emergency_com_token_url

        assert_response :success
        assert_select "h1", "Emergency Org Com Token"
      end

      test "PATCH/PUT update redirects to show" do
        patch zenith.acme_org_emergency_app_token_url

        assert_response :redirect
        assert_redirected_to zenith.acme_org_emergency_app_token_url

        put zenith.acme_org_emergency_app_token_url

        assert_response :redirect
        assert_redirected_to zenith.acme_org_emergency_app_token_url

        patch zenith.acme_org_emergency_com_token_url

        assert_response :redirect
        assert_redirected_to zenith.acme_org_emergency_com_token_url

        put zenith.acme_org_emergency_com_token_url

        assert_response :redirect
        assert_redirected_to zenith.acme_org_emergency_com_token_url
      end
    end
  end
end
