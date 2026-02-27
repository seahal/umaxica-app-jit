# typed: false
# == Schema Information
#
# Table name: com_preference_language_options
# Database name: preference
#
#  id :bigint           not null, primary key
#

# frozen_string_literal: true

class ComPreferenceLanguageOption < PreferenceRecord
  # Fixed IDs - do not modify these values
  JA = 1
  EN = 2

  has_many :com_preference_languages,
           class_name: "ComPreferenceLanguage",
           foreign_key: :option_id,
           inverse_of: :option,
           dependent: :restrict_with_error
  scope :ordered, -> { order(primary_key) }

  def name
    case id
    when JA then "ja"
    when EN then "en"
    end
  end

  self.primary_key = :id
end
