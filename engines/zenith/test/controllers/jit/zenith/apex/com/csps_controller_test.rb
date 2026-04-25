# typed: false
# frozen_string_literal: true

module Jit
  module Zenith
    require "test_helper"

    class Jit::Zenith::Acme::Com::CspsControllerTest < ActionDispatch::IntegrationTest
      test "POST /csp returns no content" do
        host! ENV["ZENITH_ACME_COM_URL"] || "com.localhost"

        payload = {
          "csp-report" => {
            "document-uri" => "https://com.localhost/",
            "violated-directive" => "script-src",
            "blocked-uri" => "inline",
            "source-file" => "https://com.localhost/assets/application.js",
          },
        }

        post zenith.acme_com_csp_url(ri: "jp"), params: payload, as: :json, headers: browser_headers

        assert_response :no_content
        assert_empty response.body
      end

      test "acme surfaces define csp helpers" do
        assert_respond_to self, :acme_com_csp_path
        assert_respond_to self, :acme_app_csp_path
        assert_respond_to self, :acme_org_csp_path
        assert_equal "/csp", zenith.acme_com_csp_path(ri: "jp")
        assert_equal "/csp", zenith.acme_app_csp_path(ri: "jp")
        assert_equal "/csp", zenith.acme_org_csp_path(ri: "jp")
      end
    end
  end
end
