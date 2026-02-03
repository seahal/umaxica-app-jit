# == Schema Information
#
# Table name: org_preference_language_options
# Database name: preference
#
#  id :bigint           not null, primary key
#

# frozen_string_literal: true

class OrgPreferenceLanguageOption < PreferenceRecord
  # Fixed IDs - do not modify these values
  JA = 1
  EN = 2

  has_many :org_preference_languages,
           class_name: "OrgPreferenceLanguage",
           foreign_key: :option_id,
           inverse_of: :option,
           dependent: :restrict_with_error
  scope :ordered, -> { order(:id) }

  def name
    case id
    when JA then "ja"
    when EN then "en"
    end
  end

  self.primary_key = :id
end
