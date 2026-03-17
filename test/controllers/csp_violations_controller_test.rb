# typed: false
# frozen_string_literal: true

require "test_helper"

class CspViolationsControllerTest < ActionDispatch::IntegrationTest
  test "create returns no_content" do
    post "/csp-violation-report"

    assert_response :no_content
  end

  test "create with csp report content type logs warning" do
    post "/csp-violation-report", headers: { "Content-Type" => "application/csp-report" }

    assert_response :no_content
  end
end
