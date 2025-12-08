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

  has_many :staff_identity_emails, dependent: :destroy
  has_many :staff_identity_telephones, dependent: :destroy
  has_many :emails, class_name: "StaffIdentityEmail", dependent: :destroy

  def staff?
    true
  end

  def user?
    false
  end
end
