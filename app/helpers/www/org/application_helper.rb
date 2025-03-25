# frozen_string_literal: true

module Www::Org::ApplicationHelper
  #
  def to_localetime(time, tz = "utc")
    raise if time.nil?

    time.in_time_zone(case tz.to_s.downcase
                      when "jst"
                        "Asia/Tokyo"
                      else
                        "UTC"
                      end)
  end
end
