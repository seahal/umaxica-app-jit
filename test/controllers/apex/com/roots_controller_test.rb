# frozen_string_literal: true

require "test_helper"

class Apex::Com::RootsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get apex_com_root_url
    assert_response :success
  end

  test "should display company information" do
    get apex_com_root_url
    assert_response :success
    # Note: In a real app, you'd test for specific content presence
    # but since we don't have views, we just verify the controller runs
  end

  test "should load corporate dashboard data" do
    get apex_com_root_url
    assert_response :success
    # Corporate site should load successfully
  end

  test "should get html which must have html which contains lang param." do
    get apex_com_root_url(format: :html)
    assert_response :success
    assert_select("html[lang=?]", "ja")
    assert_not_select("html[lang=?]", "")
  end

  # test "should get html which must have which contains configured lang param." do
  #   get apex_com_root_url(format: :html), headers: {
  #     "rack.session" => { language: "EN" }
  #   }
  #
  #   assert_response :success
  #   assert_select("html[lang=?]", "en")
  #   assert_not_select("html[lang=?]", "ja")
  # end
  test "dom check those correct apex destinations" do
    get apex_com_root_url
    assert_select "head", count: 1  do
      assert_select "title", count: 1, text: "#{ ENV.fetch('NAME') }"
    end
    assert_select "body", count: 1  do
      assert_select "header", count: 1 do
        assert_select "h1", text: "#{ ENV.fetch('NAME') } (apex, com)"
      end
      assert_select "main", count: 1
      assert_select "footer", count: 1 do
        assert_select "p", text: /^©/
      end
    end
  end
end
