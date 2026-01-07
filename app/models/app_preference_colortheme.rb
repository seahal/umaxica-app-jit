# == Schema Information
#
# Table name: app_preference_colorthemes
#
#  id            :uuid             not null, primary key
#  preference_id :uuid             not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  option_id     :string
#
# Indexes
#
#  index_app_preference_colorthemes_on_option_id      (option_id)
#  index_app_preference_colorthemes_on_preference_id  (preference_id)
#

# frozen_string_literal: true

class AppPreferenceColortheme < PreferenceRecord
  belongs_to :preference, class_name: "AppPreference", inverse_of: :app_preference_colortheme
  belongs_to :option,
             class_name: "AppPreferenceColorthemeOption",
             inverse_of: :app_preference_colorthemes,
             optional: true

  validates :preference_id, uniqueness: true
end
