# typed: false
# frozen_string_literal: true

require "test_helper"

class Apex::Com::CspsControllerTest < ActionDispatch::IntegrationTest
  test "POST /csp returns no content" do
    host! ENV["APEX_CORPORATE_URL"] || "com.localhost"

    payload = {
      "csp-report" => {
        "document-uri" => "https://com.localhost/",
        "violated-directive" => "script-src",
        "blocked-uri" => "inline",
        "source-file" => "https://com.localhost/assets/application.js",
      },
    }

    post apex_com_csp_url(ri: "jp"), params: payload, as: :json, headers: browser_headers

    assert_response :no_content
    assert_empty response.body
  end

  test "apex surfaces define csp helpers" do
    assert_respond_to self, :apex_com_csp_path
    assert_respond_to self, :apex_app_csp_path
    assert_respond_to self, :apex_org_csp_path
    assert_equal "/csp", apex_com_csp_path(ri: "jp")
    assert_equal "/csp", apex_app_csp_path(ri: "jp")
    assert_equal "/csp", apex_org_csp_path(ri: "jp")
  end
end
