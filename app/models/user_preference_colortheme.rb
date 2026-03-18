# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: user_preference_colorthemes
# Database name: principal
#
#  id            :bigint           not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  option_id     :bigint           not null
#  preference_id :bigint           not null
#
# Indexes
#
#  index_user_preference_colorthemes_on_option_id      (option_id)
#  index_user_preference_colorthemes_on_preference_id  (preference_id) UNIQUE
#
# Foreign Keys
#
#  fk_user_preference_colorthemes_on_option_id      (option_id => user_preference_colortheme_options.id)
#  fk_user_preference_colorthemes_on_preference_id  (preference_id => user_preferences.id)
#
class UserPreferenceColortheme < PrincipalRecord
  belongs_to :preference, class_name: "UserPreference", inverse_of: :user_preference_colortheme
  belongs_to :option,
             class_name: "UserPreferenceColorthemeOption",
             inverse_of: :user_preference_colorthemes,
             optional: true
  validates :preference_id, uniqueness: true
  validates :option_id, presence: true
  before_validation :set_option_id

  private

  def set_option_id
    self.option_id ||= UserPreferenceColorthemeOption::SYSTEM
  end
end
