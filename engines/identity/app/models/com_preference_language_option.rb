# typed: false
# == Schema Information
#
# Table name: com_preference_language_options
# Database name: commerce
#
#  id :bigint           not null, primary key
#

# frozen_string_literal: true

class ComPreferenceLanguageOption < CommerceRecord
  # Fixed IDs - do not modify these values
  JA = 1
  EN = 2

  has_many :com_preference_languages,
           class_name: "ComPreferenceLanguage",
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
