# == Schema Information
#
# Table name: org_preferences
# Database name: preference
#
#  id             :bigint           not null, primary key
#  compromised_at :datetime
#  expires_at     :datetime
#  jti            :string
#  revoked_at     :datetime
#  token_digest   :binary
#  used_at        :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  device_id      :string
#  public_id      :string           not null
#  replaced_by_id :bigint
#  status_id      :bigint           default(2), not null
#
# Indexes
#
#  index_org_preferences_on_device_id       (device_id)
#  index_org_preferences_on_jti             (jti) UNIQUE
#  index_org_preferences_on_public_id       (public_id) UNIQUE
#  index_org_preferences_on_replaced_by_id  (replaced_by_id)
#  index_org_preferences_on_revoked_at      (revoked_at)
#  index_org_preferences_on_status_id       (status_id)
#  index_org_preferences_on_token_digest    (token_digest)
#  index_org_preferences_on_used_at         (used_at)
#
# Foreign Keys
#
#  fk_org_preferences_on_status_id  (status_id => org_preference_statuses.id)
#  fk_rails_...                     (replaced_by_id => org_preferences.id)
#

# frozen_string_literal: true

class OrgPreference < PreferenceRecord
  include ::PublicId
  include ::ConsumeOnceToken
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
  belongs_to :replaced_by,
             class_name: "OrgPreference",
             optional: true
  has_many :replacements,
           class_name: "OrgPreference",
           foreign_key: :replaced_by_id,
           inverse_of: :replaced_by,
           dependent: :nullify
  validates :status_id, numericality: { only_integer: true }
  validates :jti, uniqueness: true, allow_nil: true
end
