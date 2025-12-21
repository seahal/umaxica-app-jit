module Auth::CommonHelper
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

  def get_timezone
    "jst"
  end

  def get_language
    "ja"
  end

  def get_region
    "jp"
  end

  def get_colortheme
    "sy"
  end
end
