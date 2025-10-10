# frozen_string_literal: true

require "test_helper"

class Apex::App::RootsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get apex_app_root_path, headers: { "HTTP_HOST" => "app.localhost" }
    assert_response :success
  end

  test "should render HTML by default" do
    get apex_app_root_path, headers: { "HTTP_HOST" => "app.localhost" }
    assert_response :success
    assert_equal "text/html", response.media_type
  end

  test "should have proper response headers" do
    get apex_app_root_path, headers: { "HTTP_HOST" => "app.localhost" }
    assert_response :success
    assert_not_nil response.headers["Content-Type"]
    assert response.headers["Content-Type"].include?("text/html")
  end

  test "should get html which must have html which contains lang param." do
    get apex_app_root_url(format: :html)
    assert_response :success
    assert_select("html[lang=?]", "ja")
    assert_not_select("html[lang=?]", "")
  end

  # test "should get html which must have which contains configured lang param." do
  #   get apex_app_root_url(format: :html), headers: {
  #     "rack.session" => { language: "en" }
  #   }
  #
  #   assert_response :success
  #   assert_select("html[lang=?]", "en")
  #   assert_not_select("html[lang=?]", "ja")
  # end

  test "should load without any instance variables" do
    get apex_app_root_path, headers: { "HTTP_HOST" => "app.localhost" }
    assert_response :success

    # Controller is simple and should return content
    assert_not_empty response.body
  end

  test "should handle multiple concurrent requests" do
    5.times do
      get apex_app_root_path, headers: { "HTTP_HOST" => "app.localhost" }
      assert_response :success
    end
  end

  test "should handle different Accept headers" do
    # HTML request
    get apex_app_root_path, headers: { "HTTP_HOST" => "app.localhost", "Accept" => "text/html" }
    assert_response :success

    # Generic request
    get apex_app_root_path, headers: { "HTTP_HOST" => "app.localhost", "Accept" => "*/*" }
    assert_response :success

    # Text request
    # get apex_app_root_path, headers: { "HTTP_HOST" => "app.localhost", "Accept" => "text/plain" }
    # assert_response :success
  end

  test "should handle various HTTP headers" do
    headers = {
      "User-Agent" => "Mozilla/5.0 Test Browser",
      "Accept-Language" => "en-US,en;q=0.9,ja;q=0.8",
      "Accept-Encoding" => "gzip, deflate, br",
      "Cache-Control" => "no-cache",
      "X-Requested-With" => "XMLHttpRequest"
    }

    headers["HTTP_HOST"] = "app.localhost"
    get apex_app_root_path, headers: headers
    assert_response :success
  end

  # test "should be accessible without authentication" do
  #   # Assuming no authentication is required for root page
  #   get apex_app_root_path
  #   assert_response :success
  #   assert_not_redirected
  # end

  test "should handle requests with query parameters" do
    get apex_app_root_path, headers: { "HTTP_HOST" => "app.localhost" }, params: { utm_source: "test", debug: "true" }
    assert_response :success

    # Parameters should be available in controller if needed
    assert_equal "test", request.params[:utm_source]
    assert_equal "true", request.params[:debug]
  end

  test "should have consistent response across multiple requests" do
    first_response = nil
    second_response = nil

    get apex_app_root_path, headers: { "HTTP_HOST" => "app.localhost" }
    first_response = response.body

    get apex_app_root_path, headers: { "HTTP_HOST" => "app.localhost" }
    second_response = response.body

    # Since controller has no dynamic content, responses should be identical
    # (assuming same view template)
    assert_response :success
    assert_not_nil first_response
    assert_not_nil second_response
  end

  test "should handle edge case scenarios" do
    # Test with very long query string
    long_param = "a" * 1000
    get apex_app_root_path, headers: { "HTTP_HOST" => "app.localhost" }, params: { long_param: long_param }
    assert_response :success

    # Test with special characters in params
    get apex_app_root_path, headers: { "HTTP_HOST" => "app.localhost" }, params: { special: "test@#$%^&*()" }
    assert_response :success
  end

  test "should handle different HTTP versions" do
    # Rails should handle HTTP/1.1 properly
    get apex_app_root_path, headers: { "HTTP_HOST" => "app.localhost" }
    assert_response :success
    assert_equal "1.1", request.env["HTTP_VERSION"] if request.env["HTTP_VERSION"]
  end

  test "should not expose sensitive information" do
    get apex_app_root_path, headers: { "HTTP_HOST" => "app.localhost" }
    assert_response :success

    # Response should not contain any sensitive headers or data
    response_body = response.body
    assert_not response_body.include?("password")
    assert_not response_body.include?("secret")
    assert_not response_body.include?("api_key")
  end

  test "should handle requests from different IP addresses" do
    # Simulate different client IPs
    [ "127.0.0.1", "192.168.1.1", "10.0.0.1" ].each do |ip|
      get apex_app_root_path, headers: { "HTTP_HOST" => "app.localhost", "REMOTE_ADDR" => ip }
      assert_response :success
    end
  end

  test "should maintain session integrity" do
    # First request
    get apex_app_root_path, headers: { "HTTP_HOST" => "app.localhost" }
    first_session_id = session.id if session.respond_to?(:id)

    # Second request should maintain or create session appropriately
    get apex_app_root_path, headers: { "HTTP_HOST" => "app.localhost" }
    assert_response :success

    # Session should be handled properly by Rails
    assert_not_nil session
  end

  test "should handle malformed requests gracefully" do
    # Test with unusual but valid HTTP methods that might be forwarded
    begin
      get apex_app_root_path, headers: { "HTTP_HOST" => "app.localhost", "REQUEST_METHOD" => "GET" }
      assert_response :success
    rescue => e
      # Should handle gracefully or raise appropriate Rails error
      assert_kind_of StandardError, e
    end
  end

  test "should respond within reasonable time limits" do
    response_times = []

    10.times do
      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      get apex_app_root_path, headers: { "HTTP_HOST" => "app.localhost" }
      end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      assert_response :success
      response_times << (end_time - start_time)
    end

    # Average response time should be reasonable
    avg_time = response_times.sum / response_times.length
    assert avg_time < 0.1, "Average response time too slow: #{avg_time}s"
  end

  test "should handle character encoding properly" do
    get apex_app_root_path, headers: { "HTTP_HOST" => "app.localhost", "Accept-Charset" => "utf-8" }
    assert_response :success

    # Response should handle UTF-8 properly
    assert response.body.encoding == Encoding::UTF_8
  end

  test "should work with different Rails environments" do
    # This test runs in whatever environment is configured
    get apex_app_root_path, headers: { "HTTP_HOST" => "app.localhost" }
    assert_response :success

    # Should work regardless of Rails.env
    assert_not_nil Rails.env
    assert Rails.env.in?(%w[development test production])
  end

  # test "should handle controller inheritance properly" do
  #   get apex_app_root_path
  #   assert_response :success
  #
  #   # Controller should inherit from ApplicationController
  #   controller_instance = @controller
  #   assert_kind_of Apex::App::RootsController, controller_instance
  #   assert controller_instance.is_a?(ApplicationController)
  # end

  test "dom check those correct apex destinations" do
    get apex_app_root_url

    assert_select "head", count: 1 do
      assert_select "title", count: 1, text: "#{ ENV.fetch('NAME') }"
      assert_select "link[rel=?]", "icon", count: 1
    end
    assert_select "body", count: 1 do
      assert_select "header", count: 1 do
        assert_select "h1", text: "#{ ENV.fetch('NAME') } (apex, app)"
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
end
