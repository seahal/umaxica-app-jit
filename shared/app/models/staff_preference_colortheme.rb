# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_preference_colorthemes
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
#  index_staff_preference_colorthemes_on_option_id      (option_id)
#  index_staff_preference_colorthemes_on_preference_id  (preference_id) UNIQUE
#
# Foreign Keys
#
#  fk_staff_preference_colorthemes_on_option_id      (option_id => staff_preference_colortheme_options.id)
#  fk_staff_preference_colorthemes_on_preference_id  (preference_id => staff_preferences.id)
#
class StaffPreferenceColortheme < PrincipalRecord
  belongs_to :preference, class_name: "StaffPreference", inverse_of: :staff_preference_colortheme
  belongs_to :option,
             class_name: "StaffPreferenceColorthemeOption",
             inverse_of: :staff_preference_colorthemes,
             optional: true
  validates :preference_id, uniqueness: true
  validates :option_id, presence: true
  before_validation :set_option_id

  private

  def set_option_id
    self.option_id ||= StaffPreferenceColorthemeOption::SYSTEM
  end
end
