# frozen_string_literal: true

require "test_helper"

class Help::Org::RootsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get help_org_root_url
    assert_response :success
  end

  test "should get html which must have html which contains lang param." do
    get help_org_root_url(format: :html)
    assert_response :success
    assert_select("html[lang=?]", "ja")
    assert_not_select("html[lang=?]", "")
  end

  test "dom check those correct apex destinations" do
    get help_org_root_url

    assert_select "head", count: 1 do
      assert_select "title", count: 1, text: "#{ ENV.fetch('NAME') }"
      assert_select "link[rel=?][sizes=?]", "icon", "32x32", count: 1
    end
    assert_select "body", count: 1 do
      assert_select "header", count: 1 do
        assert_select "h1", text: "#{ ENV.fetch('NAME') } (help, org)"
      end
      assert_select "main", count: 1
      assert_select "footer", count: 1 do
        assert_select "p", text: /^©/
      end
    end
  end
end
