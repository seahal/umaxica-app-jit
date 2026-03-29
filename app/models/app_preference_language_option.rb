# typed: false
# == Schema Information
#
# Table name: app_preference_language_options
# Database name: principal
#
#  id :bigint           not null, primary key
#

# frozen_string_literal: true

class AppPreferenceLanguageOption < PrincipalRecord
  # Fixed IDs - do not modify these values
  NOTHING = 0 # FIXME: I want to set this value.
  JA = 1
  EN = 2

  has_many :app_preference_languages,
           class_name: "AppPreferenceLanguage",
           foreign_key: :option_id,
           inverse_of: :option,
           dependent: :restrict_with_error

  def name
    case id
    when JA then "ja"
    when EN then "en"
    end
  end

  DEFAULTS = [JA, EN].freeze

  def self.ensure_defaults!
    return if DEFAULTS.blank?

    existing_ids = where(id: DEFAULTS).pluck(:id)
    missing_ids = DEFAULTS - existing_ids
    return if missing_ids.empty?

    if defined?(Prosopite)
      Prosopite.pause { missing_ids.each { |id| create!(id: id) } }
    else
      missing_ids.each { |id| create!(id: id) }
    end
  end

  self.primary_key = :id
end
