# frozen_string_literal: true

require "test_helper"

class Help::Com::RootsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get help_com_root_url

    assert_response :success
  end

  test "sets lang attribute on html element" do
    get help_com_root_url(format: :html)

    assert_response :success
    assert_select("html[lang=?]", "ja")
    assert_not_select("html[lang=?]", "")
  end
  # rubocop:disable Minitest/MultipleAssertions
  test "renders expected layout structure" do
    get help_com_root_url

    assert_select "head", count: 1 do
      assert_select "title", text: "#{brand_name} (com) Help Center"
      assert_select "link[rel=?][sizes=?]", "icon", "32x32", count: 1
    end
    assert_select "body", count: 1 do
      assert_select "header", minimum: 1
      assert_select "main", count: 1
      assert_select "footer", count: 1 do
        assert_select "small", text: /^©/
      end
    end
  end
  # rubocop:enable Minitest/MultipleAssertions

  private

    def brand_name
      (ENV["BRAND_NAME"].presence || ENV["NAME"]).to_s
    end
end
