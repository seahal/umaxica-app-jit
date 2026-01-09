# == Schema Information
#
# Table name: app_preference_languages
#
#  id            :uuid             not null, primary key
#  preference_id :uuid             not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  option_id     :string
#
# Indexes
#
#  index_app_preference_languages_on_option_id      (option_id)
#  index_app_preference_languages_on_preference_id  (preference_id) UNIQUE
#

# frozen_string_literal: true

class AppPreferenceLanguage < PreferenceRecord
  before_validation :set_option_id

  belongs_to :preference, class_name: "AppPreference", inverse_of: :app_preference_language
  belongs_to :option,
             class_name: "AppPreferenceLanguageOption",
             inverse_of: :app_preference_languages,
             optional: true

  validates :preference_id, uniqueness: true
  validates :option_id, presence: true

  private

  def set_option_id
    self.option_id ||= "JA"
  end
end
