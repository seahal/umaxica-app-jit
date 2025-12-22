# == Schema Information
#
# Table name: staffs
#
#  id          :uuid             not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  webauthn_id :string
#
class Staff < IdentitiesRecord
  # Staff represents an operator account for the staff/admin console.
  # It mirrors `User` for identity concerns but is used for staff-scoped access.
  include Account
  include Withdrawable
  include HasRoles
  include ::PublicId

  belongs_to :staff_identity_status, optional: true
  has_many :staff_identity_emails,
           dependent: :destroy
  has_many :staff_identity_telephones,
           dependent: :destroy
  has_many :staff_identity_audits,
           dependent: :destroy
  has_many :user_identity_audits,
           as: :actor,
           dependent: :destroy
  has_many :staff_identity_secrets,
           dependent: :destroy
  has_many :staff_tokens,
           dependent: :destroy

  def staff?
    true
  end

  def user?
    false
  end
end
