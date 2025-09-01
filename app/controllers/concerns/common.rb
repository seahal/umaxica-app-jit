# frozen_string_literal: true

module Common
  extend ActiveSupport::Concern

  # set url params
  def default_url_options
    tz = params["tz"].to_s.downcase == "utc" ? "utc" : ""
    lang = params["lang"].to_s.downcase == "en" ? "en" : ""

    if tz == "utc" && lang == "en"
      { tz: "utc", lang: "en" }
    elsif tz == "utc"
      { tz: "utc" }
    elsif lang == "en"
      { lang: "en" }
    else
      {}
    end
  end

  private

  # generate uuid
  def gen_original_uuid
    SecureRandom.uuid_v7
  end

  # convert utc to local time
  def localize_time(time, _zone = "Tokyo")
    time.in_time_zone("Tokyo")
  end

  # text encryption using ActiveRecord encryption
  def text_encryption(text)
    ActiveRecord::Encryption.encryptor.encrypt(text)
  end
end
