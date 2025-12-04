# frozen_string_literal: true

require "test_helper"

class Back::Org::PreferencesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get back_org_preference_url

    assert_response :success
  end

  test "show page should display content" do
    get back_org_preference_url

    assert_response :success
    assert_select "h1"
    assert_select "div.configuration-list"
  end

  test "show page should have links in configuration list" do
    get back_org_preference_url

    assert_response :success
    assert_select "div.configuration-list ul li a", minimum: 1
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "should render copyright in footer" do
    get back_org_preference_url

    assert_select "footer" do
      assert_select "small", text: /^©/
      assert_select "small", text: /#{brand_name}$/
    end
  end
  # rubocop:enable Minitest/MultipleAssertions
end
