# frozen_string_literal: true

require "test_helper"

class QueryCanonicalizerTest < ActiveSupport::TestCase
  class RequestMock
    attr_accessor :query_parameters, :path

    def initialize(query_parameters:, path: "/test", method: :get)
      @query_parameters = query_parameters
      @path = path
      @method = method
    end

    def get?
      @method == :get
    end

    def head?
      @method == :head
    end
  end

  class DummyController
    include QueryCanonicalizer

    attr_reader :request, :redirected_to, :redirect_status

    def initialize(request)
      @request = request
    end

    def redirect_to(location, allow_other_host:, status:)
      @redirected_to = location
      @redirect_status = status
    end
  end

  test "canonicalize_query_params normalizes values and redirects" do
    request = RequestMock.new(
      query_parameters: { "ri" => "us", "lx" => "fr", "ct" => "dr", "tz" => "utc" },
      path: "/help"
    )
    controller = DummyController.new(request)

    controller.send(:canonicalize_query_params)

    assert_equal "/help?ct=dr&lx=ja&ri=us&tz=utc", controller.redirected_to
    assert_equal :found, controller.redirect_status
  end

  test "canonicalize_query_params adds defaults when missing" do
    request = RequestMock.new(query_parameters: {}, path: "/help")
    controller = DummyController.new(request)

    controller.send(:canonicalize_query_params)

    assert_equal "/help?ct=sy&lx=ja&ri=jp&tz=jst", controller.redirected_to
  end

  test "canonicalize_query_params skips when already canonical" do
    request = RequestMock.new(
      query_parameters: { "ct" => "sy", "lx" => "ja", "ri" => "jp", "tz" => "jst" },
      path: "/help"
    )
    controller = DummyController.new(request)

    controller.send(:canonicalize_query_params)

    assert_nil controller.redirected_to
  end

  test "canonicalize_query_params skips for non get/head" do
    request = RequestMock.new(query_parameters: { "ct" => "sy" }, path: "/help", method: :post)
    controller = DummyController.new(request)

    controller.send(:canonicalize_query_params)

    assert_nil controller.redirected_to
  end
end
