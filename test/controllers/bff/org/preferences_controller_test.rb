# frozen_string_literal: true

require "test_helper"

class Bff::Org::PreferencesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get bff_org_preference_url

    assert_response :success
  end

  test "show page should display content" do
    get bff_org_preference_url

    assert_response :success
    assert_select "h1"
    assert_select "div.configuration-list"
  end

  test "show page should have links in configuration list" do
    get bff_org_preference_url

    assert_response :success
    assert_select "div.configuration-list ul li a", minimum: 1
  end
end
