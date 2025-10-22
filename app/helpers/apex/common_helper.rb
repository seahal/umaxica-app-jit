module Apex::CommonHelper
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

  def get_title(title = "")
    return "#{ ENV['NAME'] }" if title.blank?
    "#{ title } | #{ ENV['NAME'] }"
  end

  def get_timezone
    timezone_params = params[:tz]
    timezone_cookie =    session[:lx]

    if timezone_params
      # 1) getパラメタについてたらそれを実行する
      timezone_params
    elsif timezone_cookie
      # 2) なければ、cookie の値を実行する
      timezone_cookie
    else
      # 3) それもなければ、標準値を設定する
      "jst"
    end
  end

  def get_language
    language_params = params[:lx]
    language_cookie =    session[:lx]

    if language_params
      # 1) getパラメタについてたらそれを実行する
      language_params
    elsif language_cookie
      # 2) なければ、cookie の値を実行する
      language_cookie
    else
      # 3) それもなければ、標準値を設定する
      "ja"
    end
  end

  def get_region
    region_params = params[:ri]
    region_cookie =    session[:ri]

    if region_params
      # 1) getパラメタについてたらそれを実行する
      region_params
    elsif  region_cookie
      # 2) なければ、cookie の値を実行する
      region_cookie
    else
      # 3) それもなければ、標準値を設定する
      "jp"
    end
  end

  def get_colortheme
    color_theme_params = params[:ct]
    color_theme_session = session[:ct]

    if color_theme_params
      # 1) getパラメタについてたらそれを実行する
      color_theme_params
    elsif color_theme_session
      # 2) なければ、cookie の値を実行する
      color_theme_session
    else
      # 3) それもなければ、標準値を設定する
      "sy"
    end
  end
end
