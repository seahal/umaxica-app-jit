# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_identity_secrets
#
#  id                              :uuid             not null, primary key
#  staff_id                        :uuid             not null
#  password_digest                 :string           default(""), not null
#  last_used_at                    :datetime         default("-infinity"), not null
#  name                            :string           default(""), not null
#  staff_identity_secret_status_id :string(255)      default("ACTIVE"), not null
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  expires_at                      :datetime         default("infinity"), not null
#  uses_remaining                  :integer          default(1), not null
#
# Indexes
#
#  idx_on_staff_identity_secret_status_id_0999b0c4ae  (staff_identity_secret_status_id)
#  index_staff_identity_secrets_on_expires_at         (expires_at)
#  index_staff_identity_secrets_on_staff_id           (staff_id)
#

class StaffIdentitySecret < IdentitiesRecord
  include ::Secret

  MAX_SECRETS_PER_STAFF = 10

  belongs_to :staff
  belongs_to :staff_identity_secret_status, optional: true

  validates :staff_identity_secret_status_id, length: { maximum: 255 }
  validate :enforce_secret_limit, on: :create

  def self.identity_secret_status_class
    StaffIdentitySecretStatus
  end

  def self.identity_secret_status_id_column
    :staff_identity_secret_status_id
  end

  private

  def enforce_secret_limit
    return unless staff_id

    count = self.class.where(staff_id: staff_id).count
    return if count < MAX_SECRETS_PER_STAFF

    errors.add(:base, :too_many, message: "exceeds maximum secrets per staff (#{MAX_SECRETS_PER_STAFF})")
  end
end
