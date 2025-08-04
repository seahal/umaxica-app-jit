# frozen_string_literal: true

module Www::App::ApplicationHelper
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
end
