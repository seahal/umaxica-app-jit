# frozen_string_literal: true

module Apex::App::ApplicationHelper
  def to_localetime(time, tz = "utc")
    raise if time.nil?

    zone = case tz.to_s.downcase
    when "jst"
             "Asia/Tokyo"
    else
             "UTC"
    end

    time.in_time_zone(zone)
  end

  def title_generator(title)
    return "#{ ENV['name'] }" if title.blank?
    "#{ title } | #{ ENV['NAME'] }"
  end

  def language_setter(language = session[:language])
    language.to_s.casecmp("en").zero? ? "en" : "ja"
  end

  def show_timezone
    "jst"
  end

  def show_language
    "ja"
  end
end
