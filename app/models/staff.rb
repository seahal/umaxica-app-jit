# == Schema Information
#
# Table name: staffs
#
#  id                       :uuid             not null, primary key
#  webauthn_id              :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  public_id                :string(255)
#  staff_identity_status_id :string(255)      default("NONE")
#  withdrawn_at             :datetime
#
# Indexes
#
#  index_staffs_on_public_id                 (public_id) UNIQUE
#  index_staffs_on_staff_identity_status_id  (staff_identity_status_id)
#  index_staffs_on_withdrawn_at              (withdrawn_at)
#

class Staff < IdentitiesRecord
  # Staff represents an operator account for the staff/admin console.
  # It mirrors `User` for identity concerns but is used for staff-scoped access.

  include Withdrawable
  include HasRoles
  include ::PublicId
  include ::Account

  validates :public_id, uniqueness: true, length: { maximum: 21 }
  validates :staff_identity_status_id, length: { maximum: 255 }

  belongs_to :staff_identity_status
  has_many :staff_identity_emails,
           dependent: :restrict_with_error
  has_many :staff_identity_telephones,
           dependent: :restrict_with_error
  has_many :staff_identity_audits,
           dependent: :nullify
  has_many :user_identity_audits,
           as: :actor,
           dependent: :nullify
  has_many :staff_identity_secrets,
           dependent: :destroy
  has_many :staff_tokens,
           dependent: :nullify
  has_many :staff_messages,
           dependent: :nullify
  has_many :staff_notifications,
           dependent: :nullify

  def staff?
    true
  end

  def user?
    false
  end
end
