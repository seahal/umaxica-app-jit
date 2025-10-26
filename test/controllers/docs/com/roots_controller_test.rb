# frozen_string_literal: true

require "test_helper"

class Docs::Com::RootsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get docs_com_root_url
    assert_response :success
  end

  test "sets lang attribute on html element" do
    get docs_com_root_url(format: :html)
    assert_response :success
    assert_select("html[lang=?]", "ja")
    assert_not_select("html[lang=?]", "")
  end

  test "renders expected layout structure" do
    get docs_com_root_url

    assert_select "head", count: 1 do
      assert_select "link[rel=?][sizes=?]", "icon", "32x32", count: 1
      assert_select "title", count: 1, text: "#{ ENV.fetch('NAME') }"
    end
    assert_select "body", count: 1 do
      assert_select "header", count: 1 do
        assert_select "h1", text: "#{ ENV.fetch('NAME') } (docs, com)"
      end
      assert_select "main", count: 1
      assert_select "footer", count: 1 do
        assert_select "small", text: /^©/
      end
    end
  end
end
