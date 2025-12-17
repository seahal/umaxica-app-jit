require "test_helper"

class RedirectTest < ActiveSupport::TestCase
  include Redirect

  setup do
    @original_env = ENV.to_h
    ENV["APEX_SERVICE_URL"] = "app.sign.localdomain"
    ENV["APEX_CORPORATE_URL"] = "com.sign.localdomain"
    ENV["APEX_STAFF_URL"] = "org.sign.localdomain"
    ENV["API_SERVICE_URL"] = "app.api.localdomain"
    ENV["API_CORPORATE_URL"] = "com.api.localdomain"
    ENV["API_STAFF_URL"] = "org.api.localdomain"
    ENV["SIGN_SERVICE_URL"] = "app.sign.localdomain"
    ENV["SIGN_STAFF_URL"] = "org.sign.localdomain"
    ENV["DOCS_CORPORATE_URL"] = "com.docs.localdomain"
    ENV["DOCS_SERVICE_URL"] = "app.docs.localdomain"
    ENV["DOCS_STAFF_URL"] = "org.docs.localdomain"
    ENV["NEWS_CORPORATE_URL"] = "com.news.localdomain"
    ENV["NEWS_SERVICE_URL"] = "app.news.localdomain"
    ENV["NEWS_STAFF_URL"] = "org.news.localdomain"
    ENV["HELP_CORPORATE_URL"] = "com.docs.localdomain"
    ENV["HELP_SERVICE_URL"] = "app.docs.localdomain"
    ENV["HELP_STAFF_URL"] = "org.docs.localdomain"
    ENV["EDGE_CORPORATE_URL"] = "com.edge.localdomain"
    ENV["EDGE_SERVICE_URL"] = "app.edge.localdomain"
    ENV["EDGE_STAFF_URL"] = "org.edge.localdomain"
  end

  teardown do
    ENV.clear
    ENV.update(@original_env)
  end

  test "generate_redirect_url should reject invalid hosts" do
    invalid_url = "https://malicious.com/test"
    encoded = generate_redirect_url(invalid_url)

    assert_nil encoded
  end

  test "generate_redirect_url should reject non-https/http schemes" do
    invalid_url = "javascript:alert('xss')"
    encoded = generate_redirect_url(invalid_url)

    assert_nil encoded
  end

  test "generate_redirect_url should return nil on invalid URIs" do
    invalid_url = "not a valid uri"

    assert_nil generate_redirect_url(invalid_url)
  end

  test "generate_redirect_url should handle blank URLs" do
    encoded = generate_redirect_url("")

    assert_nil encoded

    encoded = generate_redirect_url(nil)

    assert_nil encoded
  end

  test "allowed_host? should accept exact matches" do
    assert allowed_host?("app.sign.localdomain")
  end

  test "allowed_host? should accept subdomains" do
    assert allowed_host?("sub.app.sign.localdomain")
  end

  test "allowed_host? should reject other domains" do
    assert_not allowed_host?("malicious.com")
    assert_not allowed_host?("app.sign.localdomain.evil.com")
  end

  test "allowed_host? should handle blank hosts" do
    assert_not allowed_host?("")
    assert_not allowed_host?(nil)
  end
end
