# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_passkeys
# Database name: operator
#
#  id                      :bigint           not null, primary key
#  name                    :string
#  public_key              :text             not null
#  sign_count              :integer          not null
#  transports              :string
#  user_handle             :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  external_id             :string           not null
#  staff_id                :bigint           not null
#  staff_passkey_status_id :bigint           default(0), not null
#  webauthn_id             :string           default(""), not null
#
# Indexes
#
#  index_staff_passkeys_on_external_id              (external_id)
#  index_staff_passkeys_on_staff_id                 (staff_id)
#  index_staff_passkeys_on_staff_passkey_status_id  (staff_passkey_status_id)
#  index_staff_passkeys_on_webauthn_id              (webauthn_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (staff_id => staffs.id)
#  fk_rails_...  (staff_passkey_status_id => staff_passkey_statuses.id)
#

class StaffPasskey < OperatorRecord
  self.ignored_columns += ["webauthn_id_binary"]
  MAX_PASSKEYS_PER_STAFF = 4

  belongs_to :staff, inverse_of: :staff_passkeys
  belongs_to :staff_passkey_status, optional: true

  scope :active, -> { where(staff_passkey_status_id: "ACTIVE") }

  validates :webauthn_id, presence: true, uniqueness: true
  validates :external_id, presence: true
  validates :public_key, presence: true
  validates :description, presence: true
  validates :staff_passkey_status_id, length: { maximum: 255 }
  validates :sign_count, presence: true, numericality: { greater_than_or_equal_to: 0 }

  validate :enforce_staff_passkey_limit, on: :create

  before_validation :set_defaults

  private

  def enforce_staff_passkey_limit
    return unless staff_id

    count = self.class.where(staff_id: staff_id).count
    return if count < MAX_PASSKEYS_PER_STAFF

    errors.add(:base, :too_many, message: "exceeds maximum passkeys per staff (#{MAX_PASSKEYS_PER_STAFF})")
  end

  def set_defaults
    self.external_id ||= SecureRandom.uuid
    self.sign_count ||= 0
    self.description = I18n.t("sign.default_passkey_description") if description.blank?
  end
end
