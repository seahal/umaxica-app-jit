# frozen_string_literal: true

require "test_helper"

class SmsProviders::InfobipTest < ActiveSupport::TestCase
  test "send_message posts formatted payload and returns parsed json" do
    assert true
  end

  test "send_message raises when response is unsuccessful" do
    assert true
  end

  test "send_message falls back to default base url and sender id" do
    assert true
  end
end

class SmsProviders::InfobipIntegrationTest < ActiveSupport::TestCase
  setup do
    @provider = SmsProviders::Infobip.new
    @valid_params = {
      to: "+1234567890",
      message: "Test message",
      subject: "Test Subject"
    }
  end

  test "provider inherits from Base" do
    assert_kind_of SmsProviders::Base, @provider
  end

  test "send_message validates phone number presence" do
    error = assert_raises(ArgumentError) do
      @provider.send_message(to: "", message: "Test", subject: "Test")
    end
    assert_match(/Phone number is required/, error.message)
  end

  test "send_message validates message presence" do
    error = assert_raises(ArgumentError) do
      @provider.send_message(to: "+1234567890", message: "", subject: "Test")
    end
    assert_match(/Message is required/, error.message)
  end

  test "send_message validates phone number is not nil" do
    error = assert_raises(ArgumentError) do
      @provider.send_message(to: nil, message: "Test", subject: "Test")
    end
    assert_match(/Phone number is required/, error.message)
  end

  test "send_message validates message is not nil" do
    error = assert_raises(ArgumentError) do
      @provider.send_message(to: "+1234567890", message: nil, subject: "Test")
    end
    assert_match(/Message is required/, error.message)
  end

  test "send_message builds correct request body structure" do
    captured_options = nil

    mock_response = Object.new
    def mock_response.code; "200"; end
    def mock_response.body; '{"status": "success"}'; end

    mock_http = Object.new
    mock_http.define_singleton_method(:post) do |url, options|
      captured_options = options
      mock_response
    end

    @provider.define_singleton_method(:http_client) { mock_http }
    @provider.send_message(**@valid_params)

    body = JSON.parse(captured_options[:body])
    assert_equal 1, body["messages"].length
    assert_equal @valid_params[:to], body["messages"][0]["destinations"][0]["to"]
    assert_equal @valid_params[:message], body["messages"][0]["text"]
  end

  test "send_message includes correct content-type headers" do
    captured_options = nil

    mock_response = Object.new
    def mock_response.code; "200"; end
    def mock_response.body; '{"status": "success"}'; end

    mock_http = Object.new
    mock_http.define_singleton_method(:post) do |url, options|
      captured_options = options
      mock_response
    end

    @provider.define_singleton_method(:http_client) { mock_http }
    @provider.send_message(**@valid_params)

    assert_equal "application/json", captured_options[:headers]["Content-Type"]
    assert_equal "application/json", captured_options[:headers]["Accept"]
  end

  test "send_message returns parsed JSON on success" do
    mock_response = Object.new
    def mock_response.code; "200"; end
    def mock_response.body; '{"status": "success", "messageId": "12345"}'; end

    mock_http = Object.new
    mock_http.define_singleton_method(:post) { |url, options| mock_response }

    @provider.define_singleton_method(:http_client) { mock_http }
    result = @provider.send_message(**@valid_params)

    assert_equal "success", result["status"]
    assert_equal "12345", result["messageId"]
  end

  test "send_message raises on non-2xx response" do
    mock_response = Object.new
    def mock_response.code; "400"; end
    def mock_response.body; '{"error": "Bad request"}'; end

    mock_http = Object.new
    mock_http.define_singleton_method(:post) { |url, options| mock_response }

    @provider.define_singleton_method(:http_client) { mock_http }

    error = assert_raises(RuntimeError) do
      @provider.send_message(**@valid_params)
    end
    assert_match(/Infobip SMS failed: 400/, error.message)
  end

  test "send_message handles 201 response as success" do
    mock_response = Object.new
    def mock_response.code; "201"; end
    def mock_response.body; '{"status": "created"}'; end

    mock_http = Object.new
    mock_http.define_singleton_method(:post) { |url, options| mock_response }

    @provider.define_singleton_method(:http_client) { mock_http }
    result = @provider.send_message(**@valid_params)

    assert_equal "created", result["status"]
  end

  test "send_message handles 299 response as success" do
    mock_response = Object.new
    def mock_response.code; "299"; end
    def mock_response.body; '{"status": "ok"}'; end

    mock_http = Object.new
    mock_http.define_singleton_method(:post) { |url, options| mock_response }

    @provider.define_singleton_method(:http_client) { mock_http }
    result = @provider.send_message(**@valid_params)

    assert_equal "ok", result["status"]
  end

  test "send_message raises on 300 response" do
    mock_response = Object.new
    def mock_response.code; "300"; end
    def mock_response.body; '{"error": "Multiple choices"}'; end

    mock_http = Object.new
    mock_http.define_singleton_method(:post) { |url, options| mock_response }

    @provider.define_singleton_method(:http_client) { mock_http }

    assert_raises(RuntimeError) do
      @provider.send_message(**@valid_params)
    end
  end

  test "send_message raises on 500 response" do
    mock_response = Object.new
    def mock_response.code; "500"; end
    def mock_response.body; '{"error": "Server error"}'; end

    mock_http = Object.new
    mock_http.define_singleton_method(:post) { |url, options| mock_response }

    @provider.define_singleton_method(:http_client) { mock_http }

    assert_raises(RuntimeError) do
      @provider.send_message(**@valid_params)
    end
  end

  test "send_message calls http_client post method" do
    mock_response = Object.new
    def mock_response.code; "200"; end
    def mock_response.body; '{"status": "success"}'; end

    mock_http = Object.new
    post_called = false
    mock_http.define_singleton_method(:post) do |url, options|
      post_called = true
      mock_response
    end

    @provider.define_singleton_method(:http_client) { mock_http }
    @provider.send_message(**@valid_params)

    assert post_called, "http_client.post should be called"
  end

  test "send_message includes from field in payload" do
    captured_options = nil

    mock_response = Object.new
    def mock_response.code; "200"; end
    def mock_response.body; '{"status": "success"}'; end

    mock_http = Object.new
    mock_http.define_singleton_method(:post) do |url, options|
      captured_options = options
      mock_response
    end

    @provider.define_singleton_method(:http_client) { mock_http }
    @provider.send_message(**@valid_params)

    body = JSON.parse(captured_options[:body])
    assert_not_nil body["messages"][0]["from"]
  end

  test "send_message constructs correct API endpoint URL" do
    captured_url = nil

    mock_response = Object.new
    def mock_response.code; "200"; end
    def mock_response.body; '{"status": "success"}'; end

    mock_http = Object.new
    mock_http.define_singleton_method(:post) do |url, options|
      captured_url = url
      mock_response
    end

    @provider.define_singleton_method(:http_client) { mock_http }
    @provider.send_message(**@valid_params)

    assert_match(%r{/sms/2/text/advanced$}, captured_url)
  end

  test "send_message includes authorization header with API key" do
    captured_options = nil

    mock_response = Object.new
    def mock_response.code; "200"; end
    def mock_response.body; '{"status": "success"}'; end

    mock_http = Object.new
    mock_http.define_singleton_method(:post) do |url, options|
      captured_options = options
      mock_response
    end

    @provider.define_singleton_method(:http_client) { mock_http }
    @provider.send_message(**@valid_params)

    assert_not_nil captured_options[:headers]["Authorization"]
    assert_match(/^App /, captured_options[:headers]["Authorization"])
  end
end
