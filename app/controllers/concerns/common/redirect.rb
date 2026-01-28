# frozen_string_literal: true

module Common
  module Redirect
    extend ActiveSupport::Concern

    def self.normalize_host(val)
      return nil if val.blank?

      str = val.to_s.strip
      begin
        uri = URI.parse(str)
        host = uri.host.presence || str.split("/").first
      rescue URI::InvalidURIError
        host = str
      end
      # strip scheme remnants and spaces
      host.to_s.downcase.sub(%r{^https?://}i, "").split("/").first
    end

    def allowed_hosts
      [ ENV["APEX_CORPORATE_URL"],
        ENV["APEX_SERVICE_URL"],
        ENV["APEX_STAFF_URL"],
        ENV["SIGN_SERVICE_URL"],
        ENV["SIGN_STAFF_URL"],
        ENV["DOCS_CORPORATE_URL"],
        ENV["DOCS_SERVICE_URL"],
        ENV["DOCS_STAFF_URL"],
        ENV["NEWS_CORPORATE_URL"],
        ENV["NEWS_SERVICE_URL"],
        ENV["NEWS_STAFF_URL"],
        ENV["HELP_CORPORATE_URL"],
        ENV["HELP_SERVICE_URL"],
        ENV["HELP_STAFF_URL"],
        ENV["EDGE_CORPORATE_URL"],
        ENV["EDGE_SERVICE_URL"],
        ENV["EDGE_STAFF_URL"] ].compact.filter_map { |v| Common::Redirect.normalize_host(v) }
    end

    private

      def safe_internal_path(target)
        return nil if target.blank?
        return nil if target.match?(/[[:cntrl:]]/)

        begin
          parsed_uri = URI.parse(target)
        rescue URI::InvalidURIError
          return nil
        end

        return nil if parsed_uri.scheme.present? || parsed_uri.host.present?
        return nil if parsed_uri.user.present? || parsed_uri.password.present?

        path = parsed_uri.path.presence || "/"
        return nil unless path.start_with?("/")

        query = parsed_uri.query
        query.present? ? "#{path}?#{query}" : path
      end

      def safe_external_url(url)
        return nil if url.blank?
        return nil if url.match?(/[[:cntrl:]]/)

        begin
          parsed_uri = URI.parse(url)
        rescue URI::InvalidURIError
          return nil
        end

        return nil unless %w[http https].include?(parsed_uri.scheme)
        return nil if parsed_uri.user.present? || parsed_uri.password.present?
        return nil unless allowed_host?(parsed_uri.host)

        # Reconstruct URL from parsed components to prevent parsing differential attacks
        reconstructed = URI::Generic.build(
          scheme: parsed_uri.scheme,
          host: parsed_uri.host,
          port: (parsed_uri.port == parsed_uri.default_port) ? nil : parsed_uri.port,
          path: parsed_uri.path.presence || "/",
          query: parsed_uri.query,
        ).to_s

        reconstructed
      end

      def safe_redirect_to(target, fallback: "/", **)
        safe_path = safe_internal_path(target)
        safe_url = safe_external_url(target)

        if safe_path
          redirect_to(safe_path, allow_other_host: false, **)
        elsif safe_url
          redirect_to(safe_url, allow_other_host: true, **)
        else
          redirect_to(fallback, allow_other_host: false, **)
        end
      end

      def safe_redirect_back_or_to(fallback, **)
        safe_path = safe_internal_path(request.referer)
        redirect_to(safe_path || fallback, allow_other_host: false, **)
      end

      def generate_redirect_url(url)
        safe_path = safe_internal_path(url)
        safe_url = safe_external_url(url)

        if safe_path
          Base64.urlsafe_encode64(safe_path)
        elsif safe_url
          Base64.urlsafe_encode64(safe_url)
        end
      end

      def jump_to_generated_url(encoded_url, fallback: "/")
        return redirect_to fallback if encoded_url.blank?

        begin
          decoded_url = Base64.urlsafe_decode64(encoded_url)
          safe_redirect_to(decoded_url, fallback: fallback)
        rescue ArgumentError, URI::InvalidURIError => e
          Rails.event.notify("redirect.invalid_url", error_message: e.message)
          redirect_to fallback
        end
      end

      def allowed_host?(host)
        return false if host.blank?

        host_downcase = host.downcase

        # Check for exact match or subdomain match
        allowed_hosts.any? do |allowed_host|
          host_downcase == allowed_host || host_downcase.end_with?(".#{allowed_host}")
        end
      end
  end
end
