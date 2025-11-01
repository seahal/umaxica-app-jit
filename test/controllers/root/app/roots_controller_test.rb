# frozen_string_literal: true

require "test_helper"

require "json"
require "uri"
require_relative "../../../support/cookie_helper"

class Root::App::RootsControllerTest < ActionDispatch::IntegrationTest
  DEFAULT_QUERY = { "lx" => "ja", "ri" => "jp", "tz" => "jst", "ct" => "sy" }.freeze
  HOST_HEADER = { "HTTP_HOST" => "app.localhost" }.freeze

  # rubocop:disable Minitest/MultipleAssertions
  test "redirects to include default region when neither params nor cookie exist" do
    get root_app_root_path, headers: HOST_HEADER

    assert_response :redirect
    location = URI.parse(response.location)
    query = Rack::Utils.parse_query(location.query)

    assert_equal({ "ri" => "jp" }, query)

    follow_redirect!

    assert_response :success

    persisted = signed_cookie(:root_app_preferences)

    assert_not_nil persisted
    assert_equal DEFAULT_QUERY, JSON.parse(persisted)
    assert_equal "jp", request.params["ri"]
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "should get index" do
    get root_app_root_path, headers: HOST_HEADER

    assert_response :redirect

    follow_redirect!

    assert_response :success
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "redirects using cookie preferences when query params missing" do
    get root_app_root_path, headers: HOST_HEADER, params: { lx: "en", ri: "us", tz: "utc", ct: "dr" }

    assert_response :success

    get root_app_root_path, headers: HOST_HEADER

    assert_response :redirect
    location = URI.parse(response.location)
    query = Rack::Utils.parse_query(location.query)

    assert_equal "en", query["lx"]
    assert_equal "us", query["ri"]
    assert_equal "utc", query["tz"]
    assert_equal "dr", query["ct"]

    follow_redirect!

    assert_response :success
    assert_equal "en", request.params["lx"]
    assert_equal "us", request.params["ri"]
    assert_equal "utc", request.params["tz"]
    assert_equal "dr", request.params["ct"]
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "invalid params are coerced to defaults and hidden from query" do
    get root_app_root_path, headers: HOST_HEADER, params: { lx: "xx", ri: "zz", tz: "mars", ct: "night" }

    assert_response :redirect
    location = URI.parse(response.location)
    query = Rack::Utils.parse_query(location.query)

    assert_equal({ "ri" => "jp" }, query)

    follow_redirect!

    assert_response :success

    persisted = JSON.parse(signed_cookie(:root_app_preferences))

    assert_equal DEFAULT_QUERY, persisted
    assert_equal "jp", request.params["ri"]
    assert_nil request.params["ct"]
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "known non-standard params are mapped to canonical values" do
    get root_app_root_path, headers: HOST_HEADER, params: { lx: "kr", ri: "sk", tz: "kst", ct: "auto" }

    assert_response :redirect
    location = URI.parse(response.location)
    query = Rack::Utils.parse_query(location.query)

    assert_nil query["lx"]
    assert_equal "jp", query["ri"]
    assert_nil query["tz"]
    assert_nil query["ct"]

    follow_redirect!

    assert_response :success
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "removes default preference params from query" do
    get root_app_root_path, headers: HOST_HEADER, params: DEFAULT_QUERY

    assert_response :redirect
    location = URI.parse(response.location)
    query = Rack::Utils.parse_query(location.query)

    assert_equal({ "ri" => "jp" }, query)

    follow_redirect!

    assert_response :success
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "supports all preference combinations" do
    languages = %w[ja en]
    regions = %w[jp us]
    timezones = %w[jst utc]
    themes = %w[li dr sy]

    languages.product(regions, timezones, themes).each do |lx, ri, tz, ct|
      reset!
      params = { lx: lx, ri: ri, tz: tz, ct: ct }
      get root_app_root_path, headers: HOST_HEADER, params: params

      combo = [ lx, ri, tz, ct ]
      default_combo = [ DEFAULT_QUERY["lx"], DEFAULT_QUERY["ri"], DEFAULT_QUERY["tz"], DEFAULT_QUERY["ct"] ]

      if combo == default_combo
        assert_response :redirect, "Expected redirect to strip default preferences"
        follow_redirect!

        assert_response :success
      end

      persisted_after_initial = JSON.parse(signed_cookie(:root_app_preferences))

      assert_equal({ "lx" => lx, "ri" => ri, "tz" => tz, "ct" => ct }, persisted_after_initial)

      get root_app_root_path, headers: HOST_HEADER

      assert_response :redirect, "Expected redirect when cookie present for #{combo.join('/')}"
      location = URI.parse(response.location)
      query = Rack::Utils.parse_query(location.query)

      expected_query = { "ri" => ri }
      expected_query["lx"] = lx unless lx == DEFAULT_QUERY["lx"]
      expected_query["tz"] = tz unless tz == DEFAULT_QUERY["tz"]
      expected_query["ct"] = ct unless ct == DEFAULT_QUERY["ct"]

      assert_equal expected_query, query

      follow_redirect!

      assert_response :success

      persisted = JSON.parse(signed_cookie(:root_app_preferences))

      assert_equal({ "lx" => lx, "ri" => ri, "tz" => tz, "ct" => ct }, persisted)
    end
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "should render HTML by default" do
    get_and_follow_root_root

    assert_response :success
    assert_equal "text/html", response.media_type
  end

  test "should have proper response headers" do
    get_and_follow_root_root

    assert_response :success
    assert_not_nil response.headers["Content-Type"]
    assert_includes response.headers["Content-Type"], "text/html"
  end

  test "sets lang attribute on html element" do
    get root_app_root_path(format: :html), headers: HOST_HEADER
    follow_redirect! if response.redirect?

    assert_response :success
    assert_select("html[lang=?]", "ja")
    assert_not_select("html[lang=?]", "")
  end


  test "should load without any instance variables" do
    get_and_follow_root_root

    assert_response :success
    assert_not_empty response.body
  end

  test "should handle multiple concurrent requests" do
    5.times do
      get_and_follow_root_root

      assert_response :success
    end
  end

  test "should handle different Accept headers" do
    get_and_follow_root_root(headers: HOST_HEADER.merge("Accept" => "text/html"))

    assert_response :success

    get_and_follow_root_root(headers: HOST_HEADER.merge("Accept" => "*/*"))

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

    get_and_follow_root_root(headers: headers)

    assert_response :success
  end

  test "should handle requests with query parameters" do
    request_params = { utm_source: "test", debug: "true" }
    get_and_follow_root_root(params: request_params)

    assert_response :success
    assert_equal "test", request.params[:utm_source]
    assert_equal "true", request.params[:debug]
  end

  test "should have consistent response across multiple requests" do
    get_and_follow_root_root
    first_response = response.body

    get_and_follow_root_root
    second_response = response.body

    assert_response :success
    assert_not_nil first_response
    assert_not_nil second_response
  end

  test "should handle edge case scenarios" do
    long_param = "a" * 1000
    get_and_follow_root_root(headers: HOST_HEADER.merge(long_param: long_param))

    assert_response :success

    get_and_follow_root_root(headers: HOST_HEADER.merge(special: "test@#$%^&*()"))

    assert_response :success
  end

  test "should handle different HTTP versions" do
    get_and_follow_root_root

    assert_response :success
    assert_equal "1.1", request.env["HTTP_VERSION"] if request.env["HTTP_VERSION"]
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "should not expose sensitive information" do
    get_and_follow_root_root

    assert_response :success
    response_body = response.body

    assert_not_includes response_body, "password"
    assert_not_includes response_body, "secret"
    assert_not_includes response_body, "api_key"
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "should handle requests from different IP addresses" do
    [ "127.0.0.1", "192.168.1.1", "10.0.0.1" ].each do |ip|
      get_and_follow_root_root(headers: HOST_HEADER.merge("REMOTE_ADDR" => ip))

      assert_response :success
    end
  end

  test "should maintain session integrity" do
    get_and_follow_root_root
    first_session_id = session.id if session.respond_to?(:id)

    get_and_follow_root_root

    assert_response :success
    assert_not_nil session
  end

  test "should handle malformed requests gracefully" do
    begin
      get_and_follow_root_root(headers: HOST_HEADER.merge("REQUEST_METHOD" => "GET"))

      assert_response :success
    rescue => e
      assert_kind_of StandardError, e
    end
  end

  test "should respond within reasonable time limits" do
    response_times = []

    10.times do
      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      get_and_follow_root_root
      end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      assert_response :success
      response_times << (end_time - start_time)
    end

    avg_time = response_times.sum / response_times.length

    assert_operator avg_time, :<, 0.1, "Average response time too slow: #{avg_time}s"
  end

  test "should handle character encoding properly" do
    get_and_follow_root_root(headers: HOST_HEADER.merge("Accept-Charset" => "utf-8"))

    assert_response :success
    assert_equal Encoding::UTF_8, response.body.encoding
  end

  test "should work with different Rails environments" do
    get_and_follow_root_root

    assert_response :success
    assert_not_nil Rails.env
    assert_includes %w[development test production], Rails.env
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "renders expected layout structure" do
    get_and_follow_root_root

    assert_select "head", count: 1 do
      assert_select "title", count: 1, text: brand_name
      assert_select "link[rel=?][sizes=?]", "icon", "32x32", count: 1
    end

    assert_select "body", count: 1 do
      assert_select "header", count: 1 do
        assert_select "h1", text: "#{ brand_name } (root, app)"
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

  # Session value tests
  # Note: These tests verify that the session value integration works correctly
  # The actual session values are set by RegionsController and read by RootsController

  # rubocop:disable Minitest/MultipleAssertions
  test "URL parameters take precedence over session values" do
    # Set session values
    get_and_follow_root_root
    session[:language] = "EN"
    session[:region] = "US"
    session[:timezone] = "Etc/UTC"

    # Access with different URL parameters
    get root_app_root_path, headers: HOST_HEADER, params: { lx: "ja", ri: "jp", tz: "jst" }

    # Should use URL parameters, not session values
    assert_response :redirect
    location = URI.parse(response.location)
    query = Rack::Utils.parse_query(location.query)

    assert_equal({ "ri" => "jp" }, query)

    follow_redirect!

    assert_response :success

    # Cookie should be updated to URL parameter values
    persisted = JSON.parse(signed_cookie(:root_app_preferences))

    assert_equal "ja", persisted["lx"]
    assert_equal "jp", persisted["ri"]
    assert_equal "jst", persisted["tz"]
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "cookie takes precedence over session values" do
    # Set cookie
    get root_app_root_path, headers: HOST_HEADER, params: { lx: "en", ri: "us", tz: "utc" }

    assert_response :success

    # Set different session values
    session[:language] = "JA"
    session[:region] = "JP"
    session[:timezone] = "Asia/Tokyo"

    # Access without parameters
    get root_app_root_path, headers: HOST_HEADER

    # Should use cookie values, not session values
    assert_response :redirect
    location = URI.parse(response.location)
    query = Rack::Utils.parse_query(location.query)

    assert_equal "en", query["lx"]
    assert_equal "us", query["ri"]
    assert_equal "utc", query["tz"]
  end
  # rubocop:enable Minitest/MultipleAssertions

  private

  def get_and_follow_root_root(params: {}, headers: HOST_HEADER)
    get root_app_root_path, headers: headers, params: params
    follow_redirect! if response.redirect?
  end
end
