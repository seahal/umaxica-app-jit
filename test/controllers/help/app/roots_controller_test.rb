# frozen_string_literal: true

require "test_helper"

class Help::App::RootsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get help_app_root_url

    assert_response :success
  end

  test "sets lang attribute on html element" do
    get help_app_root_url(format: :html)

    assert_response :success
    assert_select("html[lang=?]", "ja")
    assert_not_select("html[lang=?]", "")
  end

  test "renders contact link" do
    get help_app_root_url

    assert_response :success
    assert_select "a[href^=?]", new_help_app_contact_path
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "renders expected layout structure" do
    get help_app_root_url

    assert_layout_contract
    assert_select "head", count: 1 do
      assert_select "title", count: 1, text: "#{brand_name} (app) Help Center"
      assert_select "link[rel=?][sizes=?]", "icon", "32x32", count: 1
    end
    assert_select "body", count: 1 do
      assert_select "header", count: 1
      assert_select "main", count: 1
      assert_select "footer", count: 1
    end
  end
  # rubocop:enable Minitest/MultipleAssertions

  private

  def brand_name
    (ENV["BRAND_NAME"].presence || ENV["NAME"]).to_s
  end
end
