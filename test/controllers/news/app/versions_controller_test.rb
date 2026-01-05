# frozen_string_literal: true

require "test_helper"

class News::App::VersionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! ENV.fetch("NEWS_SERVICE_URL", "news.app.localhost")
  end

  test "should get index" do
    get news_app_post_versions_url(post_id: 1)
    assert_response :success
  end

  test "should get index as json" do
    get news_app_post_versions_url(post_id: 1, format: :json)
    assert_response :success
    json_response = response.parsed_body
    assert_equal 3, json_response.size
  end

  test "should get show" do
    get news_app_post_version_url(post_id: 1, id: 1)
    assert_response :success
  end

  test "should get show as json" do
    get news_app_post_version_url(post_id: 1, id: 1, format: :json)
    assert_response :success
    json_response = response.parsed_body
    assert_equal "1", json_response["id"]
    assert_equal "1.1.0", json_response["version"]
  end

  test "should get new" do
    get new_news_app_post_version_url(post_id: 1)
    assert_response :success
  end

  test "should create version" do
    post news_app_post_versions_url(post_id: 1), params: { version: { body: "foo" } }
    assert_redirected_to news_app_post_versions_url(post_id: 1)
  end

  test "should get edit" do
    get edit_news_app_post_version_url(post_id: 1, id: 1)
    assert_response :success
  end

  test "should update version" do
    patch news_app_post_version_url(post_id: 1, id: 1), params: { version: { body: "bar" } }
    assert_redirected_to news_app_post_version_url(post_id: 1, id: 1)
  end

  test "should destroy version" do
    delete news_app_post_version_url(post_id: 1, id: 1)
    assert_redirected_to news_app_post_versions_url(post_id: 1)
  end
end
