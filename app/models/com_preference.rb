# == Schema Information
#
# Table name: com_preferences
# Database name: preference
#
#  id           :uuid             not null, primary key
#  expires_at   :datetime
#  jti          :string
#  token_digest :binary
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  public_id    :string
#  status_id    :integer          default(0), not null
#
# Indexes
#
#  index_com_preferences_on_jti        (jti) UNIQUE
#  index_com_preferences_on_status_id  (status_id)
#
# Foreign Keys
#
#  fk_rails_...  (status_id => com_preference_statuses.id)
#

# frozen_string_literal: true

class ComPreference < PreferenceRecord
  include ::PublicId
  include ::Preference::Resettable

  belongs_to :com_preference_status,
             foreign_key: :status_id,
             inverse_of: :com_preferences

  has_one :com_preference_cookie,
          foreign_key: :preference_id,
          inverse_of: :preference,
          dependent: :destroy
  has_one :com_preference_region,
          foreign_key: :preference_id,
          inverse_of: :preference,
          dependent: :destroy
  has_one :com_preference_timezone,
          foreign_key: :preference_id,
          inverse_of: :preference,
          dependent: :destroy
  has_one :com_preference_language,
          foreign_key: :preference_id,
          inverse_of: :preference,
          dependent: :destroy
  has_one :com_preference_colortheme,
          foreign_key: :preference_id,
          inverse_of: :preference,
          dependent: :destroy
  has_many :com_preference_audits,
           foreign_key: :subject_id,
           inverse_of: :com_preference,
           dependent: :destroy
  validates :status_id, length: { maximum: 255 }
end
