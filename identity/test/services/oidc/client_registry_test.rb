# typed: false
# frozen_string_literal: true

require "test_helper"

class Oidc::ClientRegistryTest < ActiveSupport::TestCase
  def with_oidc_client_secret_credentials(overrides)
    creds = Rails.app.creds
    fetch = ->(key, default: nil) { overrides.fetch(key, default) }

    creds.stub(:option, fetch) do
      yield
    end
  end

  test "find returns client for known client_id" do
    client = Oidc::ClientRegistry.find("core_app")

    assert_not_nil client
    assert_equal "core_app", client.client_id
    assert_equal "umaxica-core-app", client.aud
    assert_equal "user", client.resource_type
    assert_kind_of Array, client.redirect_uris
    assert client.redirect_uris.any? { |uri| uri.include?("/auth/callback") }
  end

  test "find returns customer client for com surface" do
    client = Oidc::ClientRegistry.find("core_com")

    assert_not_nil client
    assert_equal "core_com", client.client_id
    assert_equal "umaxica-core-com", client.aud
    assert_equal "customer", client.resource_type
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
      acme_app acme_org acme_com
      core_app core_org core_com
      post_app post_org post_com
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
    %w(acme_org core_org post_org news_org help_org).each do |client_id|
      client = Oidc::ClientRegistry.find(client_id)

      assert_equal "staff", client.resource_type, "#{client_id} should be staff type"
    end
  end

  test "app clients have user resource_type" do
    %w(acme_app core_app post_app news_app help_app).each do |client_id|
      client = Oidc::ClientRegistry.find(client_id)

      assert_equal "user", client.resource_type, "#{client_id} should be user type"
    end
  end

  test "com clients have customer resource_type" do
    %w(acme_com core_com post_com news_com help_com).each do |client_id|
      client = Oidc::ClientRegistry.find(client_id)

      assert_equal "customer", client.resource_type, "#{client_id} should be customer type"
    end
  end

  test "authenticate returns false when secrets are not configured" do
    assert_not Oidc::ClientRegistry.authenticate("core_app", "any_secret")
  end

  test "find resolves secret from flat credential key" do
    with_oidc_client_secret_credentials(OIDC_CLIENT_SECRETS_FOUNDATION_BASE_APP: "core-app-secret") do
      client = Oidc::ClientRegistry.find("core_app")

      assert_equal "core-app-secret", client.client_secret
    end
  end

  test "authenticate uses flat credential key" do
    with_oidc_client_secret_credentials(OIDC_CLIENT_SECRETS_ACME_ORG: "acme-org-secret") do
      assert Oidc::ClientRegistry.authenticate("acme_org", "acme-org-secret")
      assert_not Oidc::ClientRegistry.authenticate("acme_org", "wrong-secret")
    end
  end

  test "authenticate returns false for blank secret" do
    assert_not Oidc::ClientRegistry.authenticate("core_app", "")
    assert_not Oidc::ClientRegistry.authenticate("core_app", nil)
  end

  test "client_ids returns all registered client IDs" do
    ids = Oidc::ClientRegistry.client_ids

    assert_includes ids, "core_app"
    assert_includes ids, "acme_org"
    assert_equal 15, ids.size
  end
end
