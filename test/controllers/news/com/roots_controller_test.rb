# frozen_string_literal: true

require "test_helper"


class News::Com::RootsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get news_com_root_url

    assert_response :success
  end

  test "sets lang attribute on html element" do
    get news_com_root_url(format: :html)

    assert_response :success
    assert_select("html[lang=?]", "ja")
    assert_not_select("html[lang=?]", "")
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "renders expected layout structure" do
    get news_com_root_url

    assert_select "head", count: 1 do
      assert_select "title", count: 1, text: brand_name
      assert_select "link[rel=?][sizes=?]", "icon", "32x32", count: 1
    end
    assert_select "body", count: 1 do
      assert_select "header", count: 1 do
        assert_select "h1", text: "#{ brand_name } (news, com)"
      end
      assert_select "main", count: 1
      assert_select "footer", count: 1 do
        assert_select "small", text: /^©/
      end
    end
  end
  # rubocop:enable Minitest/MultipleAssertions
end

