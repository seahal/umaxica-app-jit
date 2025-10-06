# frozen_string_literal: true

require "test_helper"

class Help::App::RootsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get help_app_root_url
    assert_response :success
  end

  test "should get html which must have html which contains lang param." do
    get help_app_root_url(format: :html)
    assert_response :success
    assert_select("html[lang=?]", "ja")
    assert_not_select("html[lang=?]", "")
  end
end
