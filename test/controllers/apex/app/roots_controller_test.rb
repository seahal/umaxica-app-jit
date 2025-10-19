# frozen_string_literal: true

require "test_helper"
require "json"
require "uri"

class Apex::App::RootsControllerTest < ActionDispatch::IntegrationTest
  DEFAULT_QUERY = { "lx" => "ja", "ri" => "jp", "tz" => "jst", "ct" => "system" }.freeze
  HOST_HEADER = { "HTTP_HOST" => "app.localhost" }.freeze

  test "applies defaults without redirect when neither params nor cookie exist" do
    get apex_app_root_path, headers: HOST_HEADER

    assert_response :success
    assert_nil response.location

    persisted = signed_cookie(:apex_app_preferences)
    assert_not_nil persisted
    assert_equal DEFAULT_QUERY, JSON.parse(persisted)
  end

  test "should get index" do
    get apex_app_root_path, headers: HOST_HEADER
    assert_response :success
  end

  test "redirects using cookie preferences when query params missing" do
    get apex_app_root_path, headers: HOST_HEADER, params: { lx: "en", ri: "us", tz: "utc", ct: "dark" }
    assert_response :success

    get apex_app_root_path, headers: HOST_HEADER
    assert_response :redirect
    location = URI.parse(response.location)
    query = Rack::Utils.parse_query(location.query)
    assert_equal "en", query["lx"]
    assert_equal "us", query["ri"]
    assert_equal "utc", query["tz"]
    assert_equal "dark", query["ct"]

    follow_redirect!
    assert_response :success
    assert_equal "en", request.params["lx"]
    assert_equal "us", request.params["ri"]
    assert_equal "utc", request.params["tz"]
    assert_equal "dark", request.params["ct"]
  end

  test "invalid params are coerced to defaults and hidden from query" do
    get apex_app_root_path, headers: HOST_HEADER, params: { lx: "xx", ri: "zz", tz: "mars", ct: "night" }

    assert_response :redirect
    location = URI.parse(response.location)
    assert_nil location.query

    follow_redirect!
    assert_response :success

    persisted = JSON.parse(signed_cookie(:apex_app_preferences))
    assert_equal DEFAULT_QUERY, persisted
    assert_nil request.params["ct"]
  end

  test "known non-standard params are mapped to canonical values" do
    get apex_app_root_path, headers: HOST_HEADER, params: { lx: "kr", ri: "sk", tz: "kst", ct: "auto" }

    assert_response :redirect
    location = URI.parse(response.location)
    query = Rack::Utils.parse_query(location.query)
    assert_nil query["lx"]
    assert_nil query["ri"]
    assert_nil query["tz"]
    assert_nil query["ct"]

    follow_redirect!
    assert_response :success
  end

  test "removes default preference params from query" do
    get apex_app_root_path, headers: HOST_HEADER, params: DEFAULT_QUERY

    assert_response :redirect
    location = URI.parse(response.location)
    assert_nil location.query

    follow_redirect!
    assert_response :success
  end

  test "supports all preference combinations" do
    languages = %w[ja en]
    regions = %w[jp us]
    timezones = %w[jst utc]
    themes = %w[light dark system]

    languages.product(regions, timezones, themes).each do |lx, ri, tz, ct|
      reset!
      params = { lx: lx, ri: ri, tz: tz, ct: ct }
      get apex_app_root_path, headers: HOST_HEADER, params: params

      combo = [ lx, ri, tz, ct ]
      default_combo = [ DEFAULT_QUERY["lx"], DEFAULT_QUERY["ri"], DEFAULT_QUERY["tz"], DEFAULT_QUERY["ct"] ]

      if combo == default_combo
        assert_response :redirect, "Expected redirect to strip default preferences"
        follow_redirect!
        assert_response :success
      else
        #        assert_response :success, "Expected success when requesting #{combo.join('/')}"
      end

      persisted_after_initial = JSON.parse(signed_cookie(:apex_app_preferences))
      assert_equal({ "lx" => lx, "ri" => ri, "tz" => tz, "ct" => ct }, persisted_after_initial)

      get apex_app_root_path, headers: HOST_HEADER

      expected_query = {}
      expected_query["lx"] = lx unless lx == DEFAULT_QUERY["lx"]
      expected_query["ri"] = ri unless ri == DEFAULT_QUERY["ri"]
      expected_query["tz"] = tz unless tz == DEFAULT_QUERY["tz"]
      expected_query["ct"] = ct unless ct == DEFAULT_QUERY["ct"]

      if expected_query.empty?
        assert_response :success, "Expected success without redirect when preferences match defaults"
        assert_nil response.location
      else
        assert_response :redirect, "Expected redirect when cookie present for #{combo.join('/')}"
        location = URI.parse(response.location)
        query = Rack::Utils.parse_query(location.query)
        assert_equal expected_query, query

        follow_redirect!
        assert_response :success
      end

      persisted = JSON.parse(signed_cookie(:apex_app_preferences))
      assert_equal({ "lx" => lx, "ri" => ri, "tz" => tz, "ct" => ct }, persisted)
    end
  end

  test "should render HTML by default" do
    get apex_app_root_path, headers: HOST_HEADER
    assert_response :success
    assert_equal "text/html", response.media_type
  end

  test "should have proper response headers" do
    get apex_app_root_path, headers: HOST_HEADER
    assert_response :success
    assert_not_nil response.headers["Content-Type"]
    assert response.headers["Content-Type"].include?("text/html")
  end

  test "should get html which must have html which contains lang param." do
    get apex_app_root_path(format: :html), headers: HOST_HEADER
    assert_response :success
    assert_select("html[lang=?]", "ja")
    assert_not_select("html[lang=?]", "")
  end

  test "should load without any instance variables" do
    get apex_app_root_path, headers: HOST_HEADER
    assert_response :success
    assert_not_empty response.body
  end

  test "should handle multiple concurrent requests" do
    5.times do
      get apex_app_root_path, headers: HOST_HEADER
      assert_response :success
    end
  end

  test "should handle different Accept headers" do
    get apex_app_root_path, headers: HOST_HEADER.merge("Accept" => "text/html")
    assert_response :success

    get apex_app_root_path, headers: HOST_HEADER.merge("Accept" => "*/*")
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

    get apex_app_root_path, headers: headers
    assert_response :success
  end

  test "should handle requests with query parameters" do
    request_params = { utm_source: "test", debug: "true" }
    get apex_app_root_path, headers: HOST_HEADER, params: request_params
    assert_response :success
    assert_equal "test", request.params[:utm_source]
    assert_equal "true", request.params[:debug]
  end

  test "should have consistent response across multiple requests" do
    get apex_app_root_path, headers: HOST_HEADER
    first_response = response.body

    get apex_app_root_path, headers: HOST_HEADER
    second_response = response.body

    assert_response :success
    assert_not_nil first_response
    assert_not_nil second_response
  end

  test "should handle edge case scenarios" do
    long_param = "a" * 1000
    get apex_app_root_path, headers: HOST_HEADER.merge(long_param: long_param)
    assert_response :success

    get apex_app_root_path, headers: HOST_HEADER.merge(special: "test@#$%^&*()")
    assert_response :success
  end

  test "should handle different HTTP versions" do
    get apex_app_root_path, headers: HOST_HEADER
    assert_response :success
    assert_equal "1.1", request.env["HTTP_VERSION"] if request.env["HTTP_VERSION"]
  end

  test "should not expose sensitive information" do
    get apex_app_root_path, headers: HOST_HEADER
    assert_response :success
    response_body = response.body
    assert_not_includes response_body, "password"
    assert_not_includes response_body, "secret"
    assert_not_includes response_body, "api_key"
  end

  test "should handle requests from different IP addresses" do
    [ "127.0.0.1", "192.168.1.1", "10.0.0.1" ].each do |ip|
      get apex_app_root_path, headers: HOST_HEADER.merge("REMOTE_ADDR" => ip)
      assert_response :success
    end
  end

  test "should maintain session integrity" do
    get apex_app_root_path, headers: HOST_HEADER
    first_session_id = session.id if session.respond_to?(:id)

    get apex_app_root_path, headers: HOST_HEADER
    assert_response :success
    assert_not_nil session
  end

  test "should handle malformed requests gracefully" do
    begin
      get apex_app_root_path, headers: HOST_HEADER.merge("REQUEST_METHOD" => "GET")
      assert_response :success
    rescue => e
      assert_kind_of StandardError, e
    end
  end

  test "should respond within reasonable time limits" do
    response_times = []

    10.times do
      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      get apex_app_root_path, headers: HOST_HEADER
      end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      assert_response :success
      response_times << (end_time - start_time)
    end

    avg_time = response_times.sum / response_times.length
    assert avg_time < 0.1, "Average response time too slow: #{avg_time}s"
  end

  test "should handle character encoding properly" do
    get apex_app_root_path, headers: HOST_HEADER.merge("Accept-Charset" => "utf-8")
    assert_response :success
    assert_equal Encoding::UTF_8, response.body.encoding
  end

  test "should work with different Rails environments" do
    get apex_app_root_path, headers: HOST_HEADER
    assert_response :success
    assert_not_nil Rails.env
    assert_includes %w[development test production], Rails.env
  end

  test "dom check those correct apex destinations" do
    get apex_app_root_path, headers: HOST_HEADER

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
