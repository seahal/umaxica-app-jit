# typed: false
# == Schema Information
#
# Table name: settings_preferences
# Database name: setting
#
#  id                       :bigint           not null, primary key
#  compromised_at           :datetime
#  dbsc_challenge           :text
#  dbsc_challenge_issued_at :datetime
#  dbsc_public_key          :jsonb
#  deletable_at             :datetime
#  device_id_digest         :string
#  expires_at               :datetime
#  jti                      :string
#  owner_type               :string
#  revoked_at               :datetime
#  shreddable_at            :datetime
#  token_digest             :binary
#  used_at                  :datetime
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  binding_method_id        :bigint           default(0), not null
#  customer_id              :bigint
#  dbsc_session_id          :string
#  dbsc_status_id           :bigint           default(0), not null
#  device_id                :string
#  owner_id                 :bigint
#  public_id                :string           not null
#  replaced_by_id           :bigint
#  staff_id                 :bigint
#  status_id                :bigint           default(0), not null
#  user_id                  :bigint
#
# Indexes
#
#  index_settings_preferences_on_binding_method_id        (binding_method_id)
#  index_settings_preferences_on_customer_id_unique       (customer_id) UNIQUE WHERE (customer_id IS NOT NULL)
#  index_settings_preferences_on_dbsc_session_id          (dbsc_session_id) UNIQUE
#  index_settings_preferences_on_dbsc_status_id           (dbsc_status_id)
#  index_settings_preferences_on_deletable_at             (deletable_at)
#  index_settings_preferences_on_device_id                (device_id)
#  index_settings_preferences_on_device_id_digest         (device_id_digest)
#  index_settings_preferences_on_jti                      (jti) UNIQUE
#  index_settings_preferences_on_owner_and_status         (owner_type,owner_id,status_id)
#  index_settings_preferences_on_owner_type_and_owner_id  (owner_type,owner_id) UNIQUE
#  index_settings_preferences_on_public_id                (public_id) UNIQUE
#  index_settings_preferences_on_replaced_by_id           (replaced_by_id)
#  index_settings_preferences_on_revoked_at               (revoked_at)
#  index_settings_preferences_on_shreddable_at            (shreddable_at)
#  index_settings_preferences_on_staff_id_unique          (staff_id) UNIQUE WHERE (staff_id IS NOT NULL)
#  index_settings_preferences_on_status_id                (status_id)
#  index_settings_preferences_on_token_digest             (token_digest)
#  index_settings_preferences_on_used_at                  (used_at)
#  index_settings_preferences_on_user_id_unique           (user_id) UNIQUE WHERE (user_id IS NOT NULL)
#
# Foreign Keys
#
#  fk_rails_...                                  (replaced_by_id => settings_preferences.id) ON DELETE => nullify
#  fk_settings_preferences_on_binding_method_id  (binding_method_id => settings_preference_binding_methods.id)
#  fk_settings_preferences_on_dbsc_status_id     (dbsc_status_id => settings_preference_dbsc_statuses.id)
#  fk_settings_preferences_on_status_id          (status_id => settings_preference_statuses.id)
#

# frozen_string_literal: true

class SettingPreference < SettingRecord
  self.table_name = "settings_preferences"
  scope :deletable, ->(now = Time.current) { where(deletable_at: ..now) }
  scope :shreddable, ->(now = Time.current) { where(shreddable_at: ..now) }

  include ::PublicId
  include ::SingleUseToken
  include ::Preference::Resettable
  include ::DbscBindable

  DBSC_BINDING_METHOD_CLASS = SettingPreferenceBindingMethod
  DBSC_STATUS_CLASS = SettingPreferenceDbscStatus

  attribute :status_id, default: SettingPreferenceStatus::NOTHING
  attribute :binding_method_id, default: SettingPreferenceBindingMethod::NOTHING
  attribute :dbsc_status_id, default: SettingPreferenceDbscStatus::NOTHING

  # Explicit owner associations (replaces polymorphic owner)
  belongs_to :user, optional: true
  belongs_to :staff, optional: true
  belongs_to :customer, optional: true

  belongs_to :setting_preference_status,
             foreign_key: :status_id,
             inverse_of: :setting_preferences
  belongs_to :setting_preference_binding_method,
             foreign_key: :binding_method_id,
             inverse_of: :setting_preferences
  belongs_to :setting_preference_dbsc_status,
             foreign_key: :dbsc_status_id,
             inverse_of: :setting_preferences

  has_one :setting_preference_cookie,
          foreign_key: :preference_id,
          inverse_of: :preference,
          dependent: :destroy
  has_one :setting_preference_region,
          foreign_key: :preference_id,
          inverse_of: :preference,
          dependent: :destroy
  has_one :setting_preference_timezone,
          foreign_key: :preference_id,
          inverse_of: :preference,
          dependent: :destroy
  has_one :setting_preference_language,
          foreign_key: :preference_id,
          inverse_of: :preference,
          dependent: :destroy
  has_one :setting_preference_colortheme,
          foreign_key: :preference_id,
          inverse_of: :preference,
          dependent: :destroy
  has_many :setting_preference_activities,
           foreign_key: :preference_id,
           inverse_of: :setting_preference,
           dependent: :destroy
  belongs_to :replaced_by,
             class_name: "SettingPreference",
             optional: true
  has_many :replacements,
           class_name: "SettingPreference",
           foreign_key: :replaced_by_id,
           inverse_of: :replaced_by,
           dependent: :nullify

  validates_reference_table :replaced_by_id, association: :replaced_by, allow_nil: true
  validates :jti, uniqueness: true, allow_nil: true
  validates :dbsc_session_id, uniqueness: true, allow_nil: true
  validates :binding_method_id, :dbsc_status_id, :status_id,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Exactly-one-owner validation
  validate :exactly_one_owner_present

  # Backward-compatible accessors for polymorphic owner migration
  def owner
    user || staff || customer
  end

  def owner_type
    return "User" if user_id.present?
    return "Staff" if staff_id.present?
    return "Customer" if customer_id.present?

    nil
  end

  def owner_id
    user_id || staff_id || customer_id
  end

  # Set owner by type (used during migration and for convenience)
  def owner=(record)
    self.user = nil
    self.staff = nil
    self.customer = nil

    case record
    when User then self.user = record
    when Staff then self.staff = record
    when Customer then self.customer = record
    end
  end

  private

  def exactly_one_owner_present
    owner_count = [user_id, staff_id, customer_id].compact.size

    return if owner_count == 1

    errors.add(:base, "must have exactly one owner (user, staff, or customer)")
  end
end
