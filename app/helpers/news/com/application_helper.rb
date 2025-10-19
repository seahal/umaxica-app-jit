# frozen_string_literal: true

module News::Com::ApplicationHelper
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
    return ENV["NAME"] if title.blank?
    "#{ title } | #{ ENV['NAME'] }"
  end
end
