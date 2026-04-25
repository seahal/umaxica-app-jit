# typed: false
# frozen_string_literal: true

require "concurrent"

module Oidc
  module ClientRegistry
    class ClientNotFound < StandardError; end

    class InvalidRedirectUri < StandardError; end

    Client = Data.define(:client_id, :client_secret, :redirect_uris, :aud, :resource_type)
    CLIENTS_MUTEX = Mutex.new
    CLIENTS_CACHE = Concurrent::AtomicReference.new(nil)

    module_function

    # @param client_id [String]
    # @return [Client, nil]
    def find(client_id)
      config = clients[client_id.to_s]
      return nil unless config

      Client.new(
        client_id: client_id.to_s,
        client_secret: resolve_secret(client_id.to_s),
        redirect_uris: config[:redirect_uris],
        aud: config[:aud],
        resource_type: config[:resource_type],
      )
    end

    # @param client_id [String]
    # @return [Client]
    # @raise [ClientNotFound]
    def find!(client_id)
      find(client_id) || raise(ClientNotFound, "Unknown OIDC client: #{client_id}")
    end

    # @param client_id [String]
    # @param uri [String]
    # @return [Boolean]
    def valid_redirect_uri?(client_id, uri)
      client = find(client_id)
      return false unless client

      client.redirect_uris.include?(uri)
    end

    # @param client_id [String]
    # @param secret [String]
    # @return [Boolean]
    def authenticate(client_id, secret)
      client = find(client_id)
      return false unless client
      return false if client.client_secret.blank? || secret.blank?

      ActiveSupport::SecurityUtils.secure_compare(client.client_secret, secret)
    end

    def client_ids
      clients.keys
    end

    # --- private ---

    def clients
      cached_clients = CLIENTS_CACHE.get
      return cached_clients if cached_clients

      CLIENTS_MUTEX.synchronize do
        CLIENTS_CACHE.get || begin
          built_clients = build_clients
          CLIENTS_CACHE.set(built_clients)
          built_clients
        end
      end
    end

    def build_clients
      {
        # Acme
        "acme_app" => {
          redirect_uris: build_redirect_uris("ZENITH_ACME_APP_URL", "app.localhost"),
          aud: "umaxica-acme-app",
          resource_type: "user",
        },
        "acme_org" => {
          redirect_uris: build_redirect_uris("ZENITH_ACME_ORG_URL", "org.localhost"),
          aud: "umaxica-acme-org",
          resource_type: "staff",
        },
        "acme_com" => {
          redirect_uris: build_redirect_uris("ZENITH_ACME_COM_URL", "com.localhost"),
          aud: "umaxica-acme-com",
          resource_type: "customer",
        },
        # Core (Legacy names, used in tests)
        "core_app" => {
          redirect_uris: build_redirect_uris("FOUNDATION_BASE_APP_URL", "base.app.localhost"),
          aud: "umaxica-foundation-app",
          resource_type: "user",
        },
        "core_org" => {
          redirect_uris: build_redirect_uris("FOUNDATION_BASE_ORG_URL", "base.org.localhost"),
          aud: "umaxica-foundation-org",
          resource_type: "staff",
        },
        "core_com" => {
          redirect_uris: build_redirect_uris("FOUNDATION_BASE_COM_URL", "base.com.localhost"),
          aud: "umaxica-foundation-com",
          resource_type: "customer",
        },
        # Foundation/Base
        "base_app" => {
          redirect_uris: build_redirect_uris("FOUNDATION_BASE_APP_URL", "base.app.localhost"),
          aud: "umaxica-foundation-app",
          resource_type: "user",
        },
        "base_org" => {
          redirect_uris: build_redirect_uris("FOUNDATION_BASE_ORG_URL", "base.org.localhost"),
          aud: "umaxica-foundation-org",
          resource_type: "staff",
        },
        "base_com" => {
          redirect_uris: build_redirect_uris("FOUNDATION_BASE_COM_URL", "base.com.localhost"),
          aud: "umaxica-foundation-com",
          resource_type: "customer",
        },
        # Docs
        "post_app" => {
          redirect_uris: build_redirect_uris("FOUNDATION_BASE_APP_URL", "base.app.localhost"), # Shared host
          aud: "umaxica-distributor-app",
          resource_type: "user",
        },
        "post_org" => {
          redirect_uris: build_redirect_uris("FOUNDATION_BASE_ORG_URL", "base.org.localhost"), # Shared host
          aud: "umaxica-distributor-org",
          resource_type: "staff",
        },
        "post_com" => {
          redirect_uris: build_redirect_uris("FOUNDATION_BASE_COM_URL", "base.com.localhost"), # Shared host
          aud: "umaxica-distributor-com",
          resource_type: "customer",
        },
        # News
        "news_app" => {
          redirect_uris: build_redirect_uris("DISTRIBUTOR_POST_APP_URL", "news.app.localhost"),
          aud: "umaxica-news-app",
          resource_type: "user",
        },
        "news_org" => {
          redirect_uris: build_redirect_uris("DISTRIBUTOR_POST_ORG_URL", "news.org.localhost"),
          aud: "umaxica-news-org",
          resource_type: "staff",
        },
        "news_com" => {
          redirect_uris: build_redirect_uris("DISTRIBUTOR_POST_COM_URL", "news.com.localhost"),
          aud: "umaxica-news-com",
          resource_type: "customer",
        },
        # Help
        "help_app" => {
          redirect_uris: build_redirect_uris("DISTRIBUTOR_POST_APP_URL", "help.app.localhost"),
          aud: "umaxica-help-app",
          resource_type: "user",
        },
        "help_org" => {
          redirect_uris: build_redirect_uris("DISTRIBUTOR_POST_ORG_URL", "help.org.localhost"),
          aud: "umaxica-help-org",
          resource_type: "staff",
        },
        "help_com" => {
          redirect_uris: build_redirect_uris("DISTRIBUTOR_POST_COM_URL", "help.com.localhost"),
          aud: "umaxica-help-com",
          resource_type: "customer",
        },
      }.freeze
    end

    def build_redirect_uris(env_key, default_host)
      host = ENV.fetch(env_key, default_host)
      protocol = Rails.env.production? ? "https" : "http"
      port_suffix = Rails.env.production? ? "" : ":#{ENV.fetch("PORT", "3000")}"
      ["#{protocol}://#{host}#{port_suffix}/auth/callback"]
    end

    def resolve_secret(client_id)
      Rails.application.credentials.oidc_client_secrets&.[](client_id.to_s.upcase)
    end

    def credential_key_for(client_id)
      :"OIDC_CLIENT_SECRETS_#{client_id.to_s.upcase}"
    end

    private_class_method :clients, :build_clients, :build_redirect_uris, :resolve_secret, :credential_key_for
  end
end
