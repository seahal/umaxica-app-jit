# frozen_string_literal: true

require "test_helper"

class News::Org::RootsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @prev_env = {
      "NEWS_STAFF_URL" => ENV["NEWS_STAFF_URL"],
      "EDGE_STAFF_URL" => ENV["EDGE_STAFF_URL"],
      "NAME" => ENV["NAME"]
    }

    # Ensure host-constrained routes and layout-rendered ENV.fetch calls work in test
    ENV["NEWS_STAFF_URL"] ||= "news.org.localdomain"
    ENV["EDGE_STAFF_URL"] ||= "edge.localdomain"
    ENV["NAME"] ||= "Umaxica"
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
    # Layout content
    assert_includes response.body, "Umaxica(news, org)"
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

  test "does not expose sensitive keywords" do
    get news_org_root_path, headers: { "HTTP_HOST" => ENV["NEWS_STAFF_URL"] }
    assert_response :success
    refute_includes response.body, "password"
    refute_includes response.body, "secret"
    refute_includes response.body, "api_key"
  end
end
