# == Schema Information
#
# Table name: com_preference_colorthemes
# Database name: preference
#
#  id            :uuid             not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  option_id     :string
#  preference_id :uuid             not null
#
# Indexes
#
#  index_com_preference_colorthemes_on_option_id      (option_id)
#  index_com_preference_colorthemes_on_preference_id  (preference_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (option_id => com_preference_colortheme_options.id)
#  fk_rails_...  (preference_id => com_preferences.id)
#

# frozen_string_literal: true

class ComPreferenceColortheme < PreferenceRecord
  belongs_to :preference, class_name: "ComPreference", inverse_of: :com_preference_colortheme
  belongs_to :option,
             class_name: "ComPreferenceColorthemeOption",
             inverse_of: :com_preference_colorthemes,
             optional: true
  validates :preference_id, uniqueness: true
  validates :option_id, presence: true
  before_validation :set_option_id

  private

  def set_option_id
    return if option_id.present?

    self.option_id = ComPreferenceColorthemeOption.find_by(id: "system")&.id || "system"
  end
end
