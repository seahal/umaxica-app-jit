# frozen_string_literal: true

require "test_helper"

class News::Com::RootsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get news_com_root_url
    assert_response :success
  end

  test "should get html which must have html which contains lang param." do
    get news_com_root_url(format: :html)
    assert_response :success
    assert_select("html[lang=?]", "ja")
    assert_not_select("html[lang=?]", "")
  end
end
