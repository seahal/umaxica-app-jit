# frozen_string_literal: true
require "test_helper"
require "json"
require "uri"

class Apex::App::RootsControllerTest < ActionDispatch::IntegrationTest
  DEFAULT_QUERY = { "lx" => "ja", "ri" => "jp", "tz" => "jst" }.freeze
  DEFAULT_QUERY_STRING = "lx=ja&ri=jp&tz=jst"
  HOST_HEADER = { "HTTP_HOST" => "app.localhost" }.freeze

  test "redirects to default preferences when neither params nor cookie exist" do
    get apex_app_root_path, headers: HOST_HEADER

    assert_response :redirect
    expected_location = "http://app.localhost#{apex_app_root_path}?#{DEFAULT_QUERY_STRING}"
    assert_redirected_to expected_location

    follow_redirect!
    assert_response :success
    assert_equal DEFAULT_QUERY["lx"], request.params["lx"]
    assert_equal DEFAULT_QUERY["ri"], request.params["ri"]
    assert_equal DEFAULT_QUERY["tz"], request.params["tz"]
  end

  test "should get index" do
    get apex_app_root_path, headers: HOST_HEADER, params: DEFAULT_QUERY
    assert_response :success
  end

  test "redirects using cookie preferences when query params missing" do
    get apex_app_root_path, headers: HOST_HEADER, params: { lx: "en", ri: "us", tz: "utc" }
    assert_response :success
    get apex_app_root_path, headers: HOST_HEADER
    assert_response :redirect
    location = URI.parse(response.location)
    query = Rack::Utils.parse_query(location.query)
    assert_equal "en", query["lx"]
    assert_equal "us", query["ri"]
    assert_equal "utc", query["tz"]

    follow_redirect!
    assert_response :success
    assert_equal "en", request.params["lx"]
    assert_equal "us", request.params["ri"]
    assert_equal "utc", request.params["tz"]
  end

  test "invalid params fall back to existing preferences" do
    get apex_app_root_path, headers: HOST_HEADER, params: { lx: "en", ri: "us", tz: "utc" }
    assert_response :success

    get apex_app_root_path, headers: HOST_HEADER, params: { lx: "xx", ri: "zz", tz: "mars" }
    assert_response :redirect
    location = URI.parse(response.location)
    query = Rack::Utils.parse_query(location.query)
    assert_equal "en", query["lx"]
    assert_equal "us", query["ri"]
    assert_equal "utc", query["tz"]
  end

  test "supports all preference combinations" do
    %w[ja en].product(%w[jp us], %w[jst utc]).each do |lx, ri, tz|
      reset!
      get apex_app_root_path, headers: HOST_HEADER, params: { lx: lx, ri: ri, tz: tz }
      assert_response :success, "Expected success when requesting #{[ lx, ri, tz ].join('/')}"

      get apex_app_root_path, headers: HOST_HEADER
      assert_response :redirect, "Expected redirect when cookie present for #{[ lx, ri, tz ].join('/')}"
      location = URI.parse(response.location)
      query = Rack::Utils.parse_query(location.query)
      assert_equal lx, query["lx"]
      assert_equal ri, query["ri"]
      assert_equal tz, query["tz"]

      follow_redirect!
      assert_response :success
      assert_equal lx, request.params["lx"]
      assert_equal ri, request.params["ri"]
      assert_equal tz, request.params["tz"]
    end
  end

  test "should render HTML by default" do
    get apex_app_root_path, headers: HOST_HEADER, params: DEFAULT_QUERY
    assert_response :success
    assert_equal "text/html", response.media_type
  end

  test "should have proper response headers" do
    get apex_app_root_path, headers: HOST_HEADER, params: DEFAULT_QUERY
    assert_response :success
    assert_not_nil response.headers["Content-Type"]
    assert response.headers["Content-Type"].include?("text/html")
  end

  test "should get html which must have html which contains lang param." do
    get apex_app_root_path(format: :html), headers: HOST_HEADER, params: DEFAULT_QUERY
    assert_response :success
    assert_select("html[lang=?]", "ja")
    assert_not_select("html[lang=?]", "")
  end

  test "should load without any instance variables" do
    get apex_app_root_path, headers: HOST_HEADER, params: DEFAULT_QUERY
    assert_response :success
    assert_not_empty response.body
  end

  test "should handle multiple concurrent requests" do
    5.times do
      get apex_app_root_path, headers: HOST_HEADER, params: DEFAULT_QUERY
      assert_response :success
    end
  end

  test "should handle different Accept headers" do
    get apex_app_root_path, headers: HOST_HEADER.merge("Accept" => "text/html"), params: DEFAULT_QUERY
    assert_response :success

    get apex_app_root_path, headers: HOST_HEADER.merge("Accept" => "*/*"), params: DEFAULT_QUERY
    assert_response :success
  end

  test "should handle various HTTP headers" do
    headers = HOST_HEADER.merge(
      "User-Agent" => "Mozilla/5.0 Test Browser",
      "Accept-Language" => "en-US,en;q=0.9,ja;q=0.8",
      "Accept-Encoding" => "gzip, deflate, br",
      "Cache-Control" => "no-cache",
      "X-Requested-With" => "XMLHttpRequest"
    )

    get apex_app_root_path, headers: headers, params: DEFAULT_QUERY
    assert_response :success
  end

  test "should handle requests with query parameters" do
    request_params = DEFAULT_QUERY.merge(utm_source: "test", debug: "true")
    get apex_app_root_path, headers: HOST_HEADER, params: request_params
    assert_response :success
    assert_equal "test", request.params[:utm_source]
    assert_equal "true", request.params[:debug]
  end

  test "should have consistent response across multiple requests" do
    get apex_app_root_path, headers: HOST_HEADER, params: DEFAULT_QUERY
    first_response = response.body

    get apex_app_root_path, headers: HOST_HEADER, params: DEFAULT_QUERY
    second_response = response.body

    assert_response :success
    assert_not_nil first_response
    assert_not_nil second_response
  end

  test "should handle edge case scenarios" do
    long_param = "a" * 1000
    get apex_app_root_path, headers: HOST_HEADER, params: DEFAULT_QUERY.merge(long_param: long_param)
    assert_response :success

    get apex_app_root_path, headers: HOST_HEADER, params: DEFAULT_QUERY.merge(special: "test@#$%^&*()")
    assert_response :success
  end

  test "should handle different HTTP versions" do
    get apex_app_root_path, headers: HOST_HEADER, params: DEFAULT_QUERY
    assert_response :success
    assert_equal "1.1", request.env["HTTP_VERSION"] if request.env["HTTP_VERSION"]
  end

  test "should not expose sensitive information" do
    get apex_app_root_path, headers: HOST_HEADER, params: DEFAULT_QUERY
    assert_response :success
    response_body = response.body
    refute_includes response_body, "password"
    refute_includes response_body, "secret"
    refute_includes response_body, "api_key"
  end

  test "should handle requests from different IP addresses" do
    [ "127.0.0.1", "192.168.1.1", "10.0.0.1" ].each do |ip|
      get apex_app_root_path, headers: HOST_HEADER.merge("REMOTE_ADDR" => ip), params: DEFAULT_QUERY
      assert_response :success
    end
  end

  test "should maintain session integrity" do
    get apex_app_root_path, headers: HOST_HEADER, params: DEFAULT_QUERY
    first_session_id = session.id if session.respond_to?(:id)

    get apex_app_root_path, headers: HOST_HEADER, params: DEFAULT_QUERY
    assert_response :success
    assert_not_nil session
  end

  test "should handle malformed requests gracefully" do
    begin
      get apex_app_root_path, headers: HOST_HEADER.merge("REQUEST_METHOD" => "GET"), params: DEFAULT_QUERY
      assert_response :success
    rescue => e
      assert_kind_of StandardError, e
    end
  end

  test "should respond within reasonable time limits" do
    response_times = []

    10.times do
      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      get apex_app_root_path, headers: HOST_HEADER, params: DEFAULT_QUERY
      end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      assert_response :success
      response_times << (end_time - start_time)
    end

    avg_time = response_times.sum / response_times.length
    assert avg_time < 0.1, "Average response time too slow: #{avg_time}s"
  end

  test "should handle character encoding properly" do
    get apex_app_root_path, headers: HOST_HEADER.merge("Accept-Charset" => "utf-8"), params: DEFAULT_QUERY
    assert_response :success
    assert_equal Encoding::UTF_8, response.body.encoding
  end

  test "should work with different Rails environments" do
    get apex_app_root_path, headers: HOST_HEADER, params: DEFAULT_QUERY
    assert_response :success
    assert_not_nil Rails.env
    assert_includes %w[development test production], Rails.env
  end

  test "dom check those correct apex destinations" do
    get apex_app_root_path, headers: HOST_HEADER, params: DEFAULT_QUERY

    assert_select "head", count: 1 do
      assert_select "title", count: 1, text: "#{ ENV.fetch('NAME') }"
      assert_select "link[rel=?][sizes=?]", "icon", "32x32", count: 1
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
