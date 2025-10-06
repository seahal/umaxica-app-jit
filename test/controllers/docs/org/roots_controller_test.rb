# frozen_string_literal: true

require "test_helper"

class Docs::Org::RootsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get docs_org_root_url
    assert_response :success
  end
  test "should get html which must have html which contains lang param." do
    get docs_org_root_url(format: :html)
    assert_response :success
    assert_select("html[lang=?]", "ja")
    assert_not_select("html[lang=?]", "")
  end
end
