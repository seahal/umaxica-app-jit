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

  def get_title(title)
    return "#{ ENV['name'] }" if title.blank?
    "#{ title } | #{ ENV['NAME'] }"
  end

  def get_timezone
    "jst"
  end

  def get_language
    "ja"
  end
end
