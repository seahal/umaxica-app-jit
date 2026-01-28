# == Schema Information
#
# Table name: org_preferences
# Database name: preference
#
#  id           :uuid             not null, primary key
#  expires_at   :datetime
#  jti          :string
#  token_digest :binary
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  public_id    :string
#  status_id    :string(255)      default("NEYO"), not null
#
# Indexes
#
#  index_org_preferences_on_jti        (jti) UNIQUE
#  index_org_preferences_on_status_id  (status_id)
#

# frozen_string_literal: true

class OrgPreference < PreferenceRecord
  include ::PublicId
  include ::Preference::Resettable

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
  has_many :org_preference_audits,
           foreign_key: :subject_id,
           inverse_of: :org_preference,
           dependent: :destroy
  validates :status_id, length: { maximum: 255 }
end
