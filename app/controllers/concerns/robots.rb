# typed: false
# frozen_string_literal: true

module Robots
  extend ActiveSupport::Concern

  private

  def show_plain_text
    response.set_header("Cache-Control", "public, max-age=3600, s-maxage=86400")
    render plain: robots_txt
  end

  def robots_txt
    case Current.surface
    when :org
      <<~ROBOTS
        User-agent: *
        Allow: /
        Disallow: /auth
        Disallow: /configuration
        Disallow: /contacts
        Disallow: /edge
        Disallow: /emergency
        Disallow: /web
      ROBOTS
    when :app
      <<~ROBOTS
        User-agent: *
        Allow: /
        Disallow: /configuration
        Disallow: /contacts
        Disallow: /edge
        Disallow: /web
      ROBOTS
    else
      "User-agent: *\nAllow: /\nDisallow:\n"
    end
  end
end
