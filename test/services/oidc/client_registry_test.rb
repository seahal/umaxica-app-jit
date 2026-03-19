# typed: false
# frozen_string_literal: true

require "test_helper"

class Oidc::ClientRegistryTest < ActiveSupport::TestCase
  test "find returns client for known client_id" do
    client = Oidc::ClientRegistry.find("core_app")

    assert_not_nil client
    assert_equal "core_app", client.client_id
    assert_equal "umaxica-core-app", client.aud
    assert_equal "user", client.resource_type
    assert_kind_of Array, client.redirect_uris
    assert client.redirect_uris.any? { |uri| uri.include?("/auth/callback") }
  end

  test "find returns nil for unknown client_id" do
    assert_nil Oidc::ClientRegistry.find("unknown_client")
  end

  test "find! raises for unknown client_id" do
    assert_raises(Oidc::ClientRegistry::ClientNotFound) do
      Oidc::ClientRegistry.find!("unknown_client")
    end
  end

  test "valid_redirect_uri? returns true for registered URI" do
    client = Oidc::ClientRegistry.find("core_app")
    uri = client.redirect_uris.first

    assert Oidc::ClientRegistry.valid_redirect_uri?("core_app", uri)
  end

  test "valid_redirect_uri? returns false for unregistered URI" do
    assert_not Oidc::ClientRegistry.valid_redirect_uri?("core_app", "https://evil.com/callback")
  end

  test "valid_redirect_uri? returns false for unknown client" do
    assert_not Oidc::ClientRegistry.valid_redirect_uri?("unknown", "http://localhost/callback")
  end

  test "all expected clients are registered" do
    expected = %w(
      apex_app apex_org apex_com
      core_app core_org core_com
      docs_app docs_org docs_com
      news_app news_org news_com
      help_app help_org help_com
    )

    expected.each do |client_id|
      client = Oidc::ClientRegistry.find(client_id)

      assert_not_nil client, "Client #{client_id} should be registered"
      assert_predicate client.redirect_uris, :present?, "Client #{client_id} should have redirect_uris"
      assert_predicate client.aud, :present?, "Client #{client_id} should have aud"
    end
  end

  test "org clients have staff resource_type" do
    %w(apex_org core_org docs_org news_org help_org).each do |client_id|
      client = Oidc::ClientRegistry.find(client_id)

      assert_equal "staff", client.resource_type, "#{client_id} should be staff type"
    end
  end

  test "app and com clients have user resource_type" do
    %w(apex_app core_app docs_app news_app help_app apex_com core_com docs_com news_com help_com).each do |client_id|
      client = Oidc::ClientRegistry.find(client_id)

      assert_equal "user", client.resource_type, "#{client_id} should be user type"
    end
  end

  test "authenticate returns false when secrets are not configured" do
    assert_not Oidc::ClientRegistry.authenticate("core_app", "any_secret")
  end

  test "authenticate returns false for blank secret" do
    assert_not Oidc::ClientRegistry.authenticate("core_app", "")
    assert_not Oidc::ClientRegistry.authenticate("core_app", nil)
  end

  test "client_ids returns all registered client IDs" do
    ids = Oidc::ClientRegistry.client_ids

    assert_includes ids, "core_app"
    assert_includes ids, "apex_org"
    assert_equal 15, ids.size
  end
end
