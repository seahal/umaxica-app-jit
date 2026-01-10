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
#  status_id    :string(255)      default("NEYO"), not null
#
# Indexes
#
#  index_app_preferences_on_status_id  (status_id)
#

# frozen_string_literal: true

class AppPreference < PreferenceRecord
  include ::PublicId

  belongs_to :app_preference_status,
             foreign_key: :status_id,
             inverse_of: :app_preferences

  validates :status_id, length: { maximum: 255 }

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
  has_many :app_preference_audits,
           foreign_key: :subject_id,
           inverse_of: :app_preference,
           dependent: :destroy
end
