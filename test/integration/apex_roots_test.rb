# typed: false
# frozen_string_literal: true

require "test_helper"

class SurfaceRootsControllerTest < ActionDispatch::IntegrationTest
  test "apex app root responds successfully" do
    get "/", headers: { "Host" => "app.localhost" }
    follow_redirect! if response.redirect?

    assert_response :success
  end

  test "apex com root responds successfully" do
    get "/", headers: { "Host" => "com.localhost" }
    follow_redirect! if response.redirect?

    assert_response :success
  end

  test "apex org root responds successfully" do
    get "/", headers: { "Host" => "org.localhost" }
    follow_redirect! if response.redirect?

    assert_response :success
  end

  test "help app root responds successfully" do
    get "/", headers: { "Host" => "help.app.localhost" }
    follow_redirect! if response.redirect?

    assert_response :success
  end

  test "help com root responds successfully" do
    get "/", headers: { "Host" => "help.com.localhost" }
    follow_redirect! if response.redirect?

    assert_response :success
  end

  test "help org root responds successfully" do
    get "/", headers: { "Host" => "help.org.localhost" }
    follow_redirect! if response.redirect?

    assert_response :success
  end

  test "news app root responds successfully" do
    get "/", headers: { "Host" => "news.app.localhost" }
    follow_redirect! if response.redirect?

    assert_response :success
  end

  test "news com root responds successfully" do
    get "/", headers: { "Host" => "news.com.localhost" }
    follow_redirect! if response.redirect?

    assert_response :success
  end

  test "news org root responds successfully" do
    get "/", headers: { "Host" => "news.org.localhost" }
    follow_redirect! if response.redirect?

    assert_response :success
  end
end

class SurfaceHealthControllerTest < ActionDispatch::IntegrationTest
  test "apex app health responds successfully" do
    get "/health", headers: { "Host" => "app.localhost" }
    follow_redirect! if response.redirect?

    assert_response :success
  end

  test "apex com health responds successfully" do
    get "/health", headers: { "Host" => "com.localhost" }
    follow_redirect! if response.redirect?

    assert_response :success
  end

  test "apex org health responds successfully" do
    get "/health", headers: { "Host" => "org.localhost" }
    follow_redirect! if response.redirect?

    assert_response :success
  end

  test "help app health responds successfully" do
    get "/health", headers: { "Host" => "help.app.localhost" }
    follow_redirect! if response.redirect?

    assert_response :success
  end

  test "help com health responds successfully" do
    get "/health", headers: { "Host" => "help.com.localhost" }
    follow_redirect! if response.redirect?

    assert_response :success
  end

  test "help org health responds successfully" do
    get "/health", headers: { "Host" => "help.org.localhost" }
    follow_redirect! if response.redirect?

    assert_response :success
  end

  test "news app health responds successfully" do
    get "/health", headers: { "Host" => "news.app.localhost" }
    follow_redirect! if response.redirect?

    assert_response :success
  end

  test "news com health responds successfully" do
    get "/health", headers: { "Host" => "news.com.localhost" }
    follow_redirect! if response.redirect?

    assert_response :success
  end

  test "news org health responds successfully" do
    get "/health", headers: { "Host" => "news.org.localhost" }
    follow_redirect! if response.redirect?

    assert_response :success
  end

  test "sign app health responds successfully" do
    get "/health", headers: { "Host" => "sign.app.localhost" }
    follow_redirect! if response.redirect?

    assert_response :success
  end

  test "sign org health responds successfully" do
    get "/health", headers: { "Host" => "sign.org.localhost" }
    follow_redirect! if response.redirect?

    assert_response :success
  end
end
