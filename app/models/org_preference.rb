# == Schema Information
#
# Table name: org_preferences
# Database name: preference
#
#  id           :bigint           not null, primary key
#  expires_at   :datetime
#  jti          :string
#  token_digest :binary
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  device_id    :string
#  public_id    :string           not null
#  status_id    :bigint           default(2), not null
#
# Indexes
#
#  index_org_preferences_on_device_id  (device_id)
#  index_org_preferences_on_jti        (jti) UNIQUE
#  index_org_preferences_on_public_id  (public_id) UNIQUE
#  index_org_preferences_on_status_id  (status_id)
#
# Foreign Keys
#
#  fk_org_preferences_on_status_id  (status_id => org_preference_statuses.id)
#

# frozen_string_literal: true

class OrgPreference < PreferenceRecord
  include ::PublicId
  include ::Preference::Resettable

  attribute :status_id, default: OrgPreferenceStatus::NEYO

  belongs_to :org_preference_status,
             foreign_key: :status_id,
             inverse_of: :org_preferences

  has_one :org_preference_cookie,
          foreign_key: :preference_id,
          inverse_of: :preference,
          dependent: :destroy
  has_one :org_preference_region,
          foreign_key: :preference_id,
          inverse_of: :preference,
          dependent: :destroy
  has_one :org_preference_timezone,
          foreign_key: :preference_id,
          inverse_of: :preference,
          dependent: :destroy
  has_one :org_preference_language,
          foreign_key: :preference_id,
          inverse_of: :preference,
          dependent: :destroy
  has_one :org_preference_colortheme,
          foreign_key: :preference_id,
          inverse_of: :preference,
          dependent: :destroy
  has_many :org_preference_activities,
           foreign_key: :subject_id,
           inverse_of: :org_preference,
           dependent: :destroy
  validates :status_id, numericality: { only_integer: true }
  validates :jti, uniqueness: true, allow_nil: true
end
