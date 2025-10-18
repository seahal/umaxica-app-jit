# frozen_string_literal: true

require "test_helper"

class Apex::Org::HealthsControllerTest < ActionDispatch::IntegrationTest
  test "responds with OK for html variants" do
    assert_health_html_variants(:apex_org_health_url)
  end

  test "responds with OK for json" do
    assert_health_json(:apex_org_health_url)
  end

  test "raises when requesting yaml format" do
    assert_health_invalid_format(:apex_org_health_url, :yaml)
  end
end
