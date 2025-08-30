# frozen_string_literal: true

require "test_helper"

class Docs::Org::HealthsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get docs_org_health_url
    assert_response :success
    assert_equal "OK", @response.body
    # assert_select "a[href=?]", www_com_root_path, count: 0
  end

  test "should get show with postfix" do
    get docs_org_health_url(format: :html)
    assert_response :success
    assert_equal "OK", @response.body
    # assert_select "a[href=?]", www_com_root_path, count: 0
  end

  test "should get show with postfix json" do
    get docs_org_health_url(format: :json)
    assert_response :success
    assert_equal "OK", @response.parsed_body["status"]
  end

  test "should not get show when required yaml file" do
    assert_raises(RuntimeError) do
      get docs_org_health_url(format: :yaml)
    end
  end
end
