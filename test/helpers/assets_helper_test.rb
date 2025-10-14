# frozen_string_literal: true

require "test_helper"

class AssetsHelperTest < ActionView::TestCase
  setup do
    extend AssetsHelper
  end

  test "tenant_key returns org when host contains org" do
    @controller.request.host = "app.umaxica.org"

    assert_equal "org", tenant_key
  end

  test "tenant_key returns net when host ends with net tld" do
    @controller.request.host = "cdn.umaxica.net"

    assert_equal "net", tenant_key
  end

  test "tenant_key falls back to com for other hosts" do
    @controller.request.host = "www.umaxica.com"

    assert_equal "com", tenant_key
  end
end
