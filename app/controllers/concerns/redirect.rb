# frozen_string_literal: true

module Redirect
  extend ActiveSupport::Concern
  ALLOWED_HOSTS = [ "app.www.localdomain" ].map(&:downcase).freeze

  private

  def generate_redirect_url(url)
    return nil if url.blank?

    parsed_uri = URI.parse(url)

    # Only allow specific hosts and schemes
    if allowed_host?(parsed_uri.host) && %w[http https].include?(parsed_uri.scheme)
      Base64.urlsafe_encode64(url)
    else
      nil
    end
  rescue URI::InvalidURIError
    nil
  end

  def jump_to_generated_url(encoded_url)
    return redirect_to "/" if encoded_url.blank?

    begin
      decoded_url = Base64.urlsafe_decode64(encoded_url)
      parsed_uri = URI.parse(decoded_url)

      # Double-check the URL is still safe after decoding
      if allowed_host?(parsed_uri.host) && %w[http https].include?(parsed_uri.scheme)
        redirect_to parsed_uri.to_s
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
