# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_preference_languages
# Database name: guest
#
#  id            :bigint           not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  option_id     :bigint           not null
#  preference_id :bigint           not null
#
# Indexes
#
#  index_customer_preference_languages_on_option_id      (option_id)
#  index_customer_preference_languages_on_preference_id  (preference_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (option_id => customer_preference_language_options.id)
#  fk_rails_...  (preference_id => customer_preferences.id)
#
class CustomerPreferenceLanguage < GuestRecord
  belongs_to :preference, class_name: "CustomerPreference", inverse_of: :customer_preference_language
  belongs_to :option,
             class_name: "CustomerPreferenceLanguageOption",
             inverse_of: :customer_preference_languages,
             optional: true

  validates :preference_id, uniqueness: true
  validates :option_id, presence: true

  before_validation :set_option_id

  private

  def set_option_id
    self.option_id ||= CustomerPreferenceLanguageOption::JA
  end
end
