# typed: false
# == Schema Information
#
# Table name: org_preference_languages
# Database name: preference
#
#  id            :bigint           not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  option_id     :bigint           not null
#  preference_id :bigint           not null
#
# Indexes
#
#  index_org_preference_languages_on_option_id      (option_id)
#  index_org_preference_languages_on_preference_id  (preference_id) UNIQUE
#
# Foreign Keys
#
#  fk_org_preference_languages_on_option_id  (option_id => org_preference_language_options.id)
#  fk_rails_...                              (preference_id => org_preferences.id)
#

# frozen_string_literal: true

class OrgPreferenceLanguage < PreferenceRecord
  belongs_to :preference, class_name: "OrgPreference", inverse_of: :org_preference_language
  belongs_to :option,
             class_name: "OrgPreferenceLanguageOption",
             inverse_of: :org_preference_languages,
             optional: true

  validates :preference_id, uniqueness: true
  validates :option_id, presence: true

  before_validation :set_option_id

  private

  def set_option_id
    self.option_id ||= OrgPreferenceLanguageOption::JA
  end
end
