# frozen_string_literal: true

require "test_helper"

class News::Org::RootsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @prev_env = {
      "NEWS_STAFF_URL" => ENV["NEWS_STAFF_URL"],
      "EDGE_STAFF_URL" => ENV["EDGE_STAFF_URL"],
      "NAME" => ENV["NAME"],
      "BRAND_NAME" => ENV["BRAND_NAME"],
    }

    # Ensure host-constrained routes and layout-rendered ENV.fetch calls work in test
    ENV["NEWS_STAFF_URL"] ||= "news.org.localdomain"
    ENV["EDGE_STAFF_URL"] ||= "edge.localdomain"
    ENV["NAME"] ||= "Umaxica"
    ENV["BRAND_NAME"] ||= ENV["NAME"]
  end

  def teardown
    @prev_env.each { |k, v| v.nil? ? ENV.delete(k) : ENV[k] = v }
  end

  test "should get index with staff host" do
    get news_org_root_path, headers: { "HTTP_HOST" => ENV["NEWS_STAFF_URL"] }

    assert_response :success
  end

  test "renders HTML by default" do
    get news_org_root_path, headers: { "HTTP_HOST" => ENV["NEWS_STAFF_URL"] }

    assert_response :success
    assert_equal "text/html", response.media_type
  end

  test "includes view and layout content" do
    get news_org_root_path, headers: { "HTTP_HOST" => ENV["NEWS_STAFF_URL"] }

    assert_response :success
    # View content
    assert_includes response.body, "Www::Org::Roots#index"
  end

  test "handles query params" do
    get news_org_root_path,
        headers: { "HTTP_HOST" => ENV["NEWS_STAFF_URL"] },
        params: { utm_source: "test-suite", debug: "1" }

    assert_response :success
    assert_equal "test-suite", request.params[:utm_source]
    assert_equal "1", request.params[:debug]
  end

  test "consistent across multiple requests" do
    3.times do
      get news_org_root_path, headers: { "HTTP_HOST" => ENV["NEWS_STAFF_URL"] }

      assert_response :success
      assert_includes response.body, "Www::Org::Roots#index"
    end
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "does not expose sensitive keywords" do
    get news_org_root_path, headers: { "HTTP_HOST" => ENV["NEWS_STAFF_URL"] }

    assert_response :success
    assert_not_includes response.body, "password"
    assert_not_includes response.body, "secret"
    assert_not_includes response.body, "api_key"
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "sets lang attribute on html element" do
    get news_org_root_url(format: :html)

    assert_response :success
    assert_select("html[lang=?]", "ja")
    assert_not_select("html[lang=?]", "")
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "renders expected layout structure" do
    get news_org_root_url

    assert_select "head", count: 1 do
      assert_select "title", count: 1, text: "#{brand_name} (org) Newsroom"
      assert_select "link[rel=?][sizes=?]", "icon", "32x32", count: 1
    end
    assert_select "body", count: 1 do
      assert_select "header", count: 1 do
        assert_select "h1", text: /#{brand_name}.*\(news, org\)/
      end
      assert_select "main", count: 1
      assert_select "footer", count: 1 do
        assert_select "ul" do
          assert_select "li"
        end
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
