# == Schema Information
#
# Table name: org_preference_language_options
#
#  id         :string           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# frozen_string_literal: true

class OrgPreferenceLanguageOption < PreferenceRecord
  self.primary_key = :id

  has_many :org_preference_languages,
           class_name: "OrgPreferenceLanguage",
           foreign_key: :option_id,
           inverse_of: :option,
           dependent: :restrict_with_error
end
