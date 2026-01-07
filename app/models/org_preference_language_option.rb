# == Schema Information
#
# Table name: org_preference_language_options
#
#  id :uuid             not null, primary key
#

# frozen_string_literal: true

class OrgPreferenceLanguageOption < PreferenceRecord
  has_many :org_preference_languages,
           class_name: "OrgPreferenceLanguage",
           foreign_key: :option_id,
           inverse_of: :option,
           dependent: :restrict_with_error
end
