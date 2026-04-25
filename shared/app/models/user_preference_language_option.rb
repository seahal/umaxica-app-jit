# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: user_preference_language_options
# Database name: principal
#
#  id :bigint           not null, primary key
#
class UserPreferenceLanguageOption < PrincipalRecord
  # Fixed IDs - do not modify these values
  NOTHING = 0
  JA = 1
  EN = 2

  has_many :user_preference_languages,
           class_name: "UserPreferenceLanguage",
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

  def self.default_ids
    DEFAULTS
  end

  def self.ensure_defaults!
    return if default_ids.blank?

    existing_ids = where(id: default_ids).pluck(:id)
    missing_ids = default_ids - existing_ids
    return if missing_ids.empty?

    if defined?(Prosopite)
      Prosopite.pause { missing_ids.each { |id| create!(id: id) } }
    else
      missing_ids.each { |id| create!(id: id) }
    end
  end

  self.primary_key = :id
end
