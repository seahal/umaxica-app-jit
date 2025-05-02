# frozen_string_literal: true

module Redirect
  extend ActiveSupport::Concern
  HOST_URI = [ "app.www.localdomain" ].map(&:downcase)

  private

  def generate_redirect_url(url)
    parsed_uri = URI.parse(url)
    return Base64.urlsafe_encode64(url) if HOST_URI.any? { it == parsed_uri.host }
    raise URI::InvalidURIError
  end

  def jump_to_generated_url(chars)
    redirect_to "/" if chars.blank?

    parsed_uri = URI.parse(Base64.urlsafe_decode64(url))

    # checking url
    if HOST_URI.any? { it == parsed_uri.host.split(".")[-2..-1].join(".").downcase } && %w[http https].include?(parsed_uri.scheme)
      redirect_to uri
    else
      head :not_found
    end

  rescue NoMethodError # そもそも uri じゃない文字列を除外する
    head :not_found
  rescue URI::InvalidURIError # "iiii" とか防止
    head :not_found
  end
end
