# typed: false
# frozen_string_literal: true

module Post::CommonHelper
  def to_localetime(time, tz = "utc")
    return nil if time.nil?

    zone =
      case tz.to_s.downcase
      when "jst"
        "Asia/Tokyo"
      else
        "UTC"
      end

    time.in_time_zone(zone)
  end

  def get_title(title = "")
    brand_name = (ENV["BRAND_NAME"].presence || ENV["NAME"]).to_s
    return brand_name if title.blank?

    "#{title} | #{brand_name}"
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

  def cms_document_latest_version(document)
    document.com_document_versions.order(created_at: :desc).first
  end

  def cms_document_title(document, fallback: content_tag(:span, "No version", class: "italic"))
    version = cms_document_latest_version(document)
    return fallback if version.blank?

    safe_encrypted_text(version, :title, fallback:)
  end

  def safe_encrypted_text(record, attribute, fallback: nil)
    value = record.public_send(attribute)
    value.presence || fallback
  rescue ActiveRecord::Encryption::Errors::Decryption
    fallback
  end
end
