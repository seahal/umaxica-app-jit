# frozen_string_literal: true

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
  include Stakeholder

  belongs_to :staff_identity_status, optional: true
  has_many :staff_identity_emails, dependent: :destroy
  has_many :staff_identity_telephones, dependent: :destroy
  has_many :staff_identity_audits, dependent: :destroy
  # what is this association for?
  has_many :emails, class_name: "StaffIdentityEmail", dependent: :destroy

  def staff?
    true
  end

  def user?
    false
  end
end
