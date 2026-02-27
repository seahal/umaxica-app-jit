# typed: false
# == Schema Information
#
# Table name: app_preference_language_options
# Database name: preference
#
#  id :bigint           not null, primary key
#

# frozen_string_literal: true

class AppPreferenceLanguageOption < PreferenceRecord
  # Fixed IDs - do not modify these values
  NOTHING = 0 # I want to set this value.
  JA = 1
  EN = 2

  has_many :app_preference_languages,
           class_name: "AppPreferenceLanguage",
           foreign_key: :option_id,
           inverse_of: :option,
           dependent: :restrict_with_error
  scope :ordered, -> { all }

  def name
    case id
    when JA then "ja"
    when EN then "en"
    end
  end

  def self.ensure_defaults!
    ids = [JA, EN]
    existing = where(id: ids).pluck(:id)
    (ids - existing).each { |id| create!(id: id) }
  end

  self.primary_key = :id
end
