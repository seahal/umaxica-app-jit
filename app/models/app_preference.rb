# == Schema Information
#
# Table name: app_preferences
#
#  id           :uuid             not null, primary key
#  public_id    :string
#  expires_at   :datetime
#  token_digest :binary
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

# frozen_string_literal: true

class AppPreference < PreferenceRecord
  include ::PublicId

  has_one :app_preference_cookie,
          foreign_key: :preference_id,
          inverse_of: :preference,
          dependent: :destroy
  has_one :app_preference_region,
          foreign_key: :preference_id,
          inverse_of: :preference,
          dependent: :destroy
  has_one :app_preference_timezone,
          foreign_key: :preference_id,
          inverse_of: :preference,
          dependent: :destroy
  has_one :app_preference_language,
          foreign_key: :preference_id,
          inverse_of: :preference,
          dependent: :destroy
  has_one :app_preference_colortheme,
          foreign_key: :preference_id,
          inverse_of: :preference,
          dependent: :destroy
end
