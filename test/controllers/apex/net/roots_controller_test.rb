# frozen_string_literal: true

require "test_helper"

class Apex::Net::RootsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get apex_net_root_url
    assert_response :success
  end

  test "index links point to correct apex destinations" do
    get apex_net_root_url
    assert_response :success

    assert_select "ul" do
      assert_select "li > a[href=?]", apex_com_root_url, text: "corporate site"
      assert_select "li > a[href=?]", apex_app_root_url, text: "service site"
      assert_select "li > a[href=?]", apex_org_root_url, text: "staff site"
      assert_select "li", count: 3
    end
  end

  test "dom check those correct apex destinations" do
    get apex_net_root_url

    assert_select "body" do
      assert_select "header", count: 1 do
        assert_select "h1", text: "#{ ENV.fetch('NAME') } (net)"
      end
      assert_select "main", count: 1
      assert_select "footer", count: 1
    end
  end

  test "should get html which must have html which contains lang param." do
    get apex_net_root_url(format: :html)
    assert_response :success
    assert_select("html[lang=?]", "ja")
    assert_not_select("html[lang=?]", "")
  end
end
