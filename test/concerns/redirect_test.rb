require "test_helper"

class RedirectTest < ActiveSupport::TestCase
  include Redirect

  test "generate_redirect_url should encode valid URLs" do
    valid_url = "https://app.www.localdomain/test"
    encoded = generate_redirect_url(valid_url)

    assert_not_nil encoded
    assert_equal valid_url, Base64.urlsafe_decode64(encoded)
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

  test "generate_redirect_url should handle blank URLs" do
    encoded = generate_redirect_url("")
    assert_nil encoded

    encoded = generate_redirect_url(nil)
    assert_nil encoded
  end

  test "allowed_host? should accept exact matches" do
    assert allowed_host?("app.www.localdomain")
  end

  test "allowed_host? should accept subdomains" do
    assert allowed_host?("sub.app.www.localdomain")
  end

  test "allowed_host? should reject other domains" do
    assert_not allowed_host?("malicious.com")
    assert_not allowed_host?("app.www.localdomain.evil.com")
  end

  test "allowed_host? should handle blank hosts" do
    assert_not allowed_host?("")
    assert_not allowed_host?(nil)
  end
end
