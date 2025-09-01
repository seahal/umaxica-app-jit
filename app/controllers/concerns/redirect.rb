# frozen_string_literal: true

module Redirect
  extend ActiveSupport::Concern
  ALLOWED_HOSTS = [ ENV["WWW_CORPORATE_URL"],
                   ENV["WWW_SERVICE_URL"],
                   ENV["WWW_STAFF_URL"],
                   ENV["API_CORPORATE_URL"],
                   ENV["API_SERVICE_URL"],
                   ENV["API_STAFF_URL"],
                   ENV["AUTH_SERVICE_URL"],
                   ENV["AUTH_STAFF_URL"],
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
                   ENV["EDGE_STAFF_URL"] ].compact.map(&:downcase).freeze

  private

  # TODO: rewrite!
  def generate_redirect_url(url)
    return nil if url.blank?

    parsed_uri = URI.parse(url)

    # Only allow specific hosts and schemes
    if allowed_host?(parsed_uri.host) && %w[http https].include?(parsed_uri.scheme)
      Base64.urlsafe_encode64(url)
    else
      nil
    end
  end

  # TODO: rewrite!
  def jump_to_generated_url(encoded_url)
    return redirect_to "/" if encoded_url.blank?

    begin
      decoded_url = Base64.urlsafe_decode64(encoded_url)
      parsed_uri = URI.parse(decoded_url)

      # Double-check the URL is still safe after decoding
      if allowed_host?(parsed_uri.host) && %w[http https].include?(parsed_uri.scheme)
        redirect_to parsed_uri.to_s, allow_other_host: true
      else
        head :not_found
      end
    rescue ArgumentError, URI::InvalidURIError => e
      Rails.logger.warn "Invalid redirect URL attempted: #{e.message}"
      head :not_found
    end
  end

  def allowed_host?(host)
    return false if host.blank?

    host_downcase = host.downcase

    # Check for exact match or subdomain match
    ALLOWED_HOSTS.any? do |allowed_host|
      host_downcase == allowed_host ||
        host_downcase.end_with?(".#{allowed_host}")
    end
  end
end
