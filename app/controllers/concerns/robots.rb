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
      "User-agent: *\nDisallow: /\n"
    when :app
      "User-agent: *\nDisallow: /configuration\nDisallow: /api\nDisallow: /web\n"
    else
      "User-agent: *\nDisallow:\n"
    end
  end
end
